//
//  MainViewerController.m
//  instagram-viewer
//
//  Created by chen zhejun on 11/7/15.
//  Copyright © 2015 superdami. All rights reserved.
//

#import "MainViewerController.h"
#import "InstagramKit.h"
#import "GridCell.h"
#import "InstagramMedia.h"
#import "DetailViewController.h"
#import "UserViewController.h"
#import "IVLoader.h"
#import "RNPullToActionControl.h"

#define kNumberOfCellsInARow 3
#define kFetchItemsCount 30
@interface MainViewerController ()
@property (nonatomic, weak) InstagramEngine *instagramEngine;
@property (nonatomic, weak) IVLoader *loader;
@property (nonatomic, strong) RNPullToActionControl *refreshControler;
@end

@implementation MainViewerController

- (instancetype)init {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setMinimumInteritemSpacing:1.0f];
    [layout setMinimumLineSpacing:1.0f];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    if (self = [super initWithCollectionViewLayout:layout]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    self.collectionView.backgroundColor = [UIColor darkGrayColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.instagramEngine = [InstagramEngine sharedEngine];
    self.loader = [IVLoader shareInstance];
    [self updateCollectionViewLayout];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userAuthenticationChanged:)
                                                 name:InstagramKitUserAuthenticationChangedNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaDataUpdated:)
                                                 name:IVLoaderMediaDataUpdated
                                               object:nil];
    
    [self.collectionView registerClass:[GridCell class] forCellWithReuseIdentifier:@"CPCELL"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"User" style:UIBarButtonItemStyleDone target:self action:@selector(userTapped:)];
    
    [self createRefreshControl];
    [self loadMedia];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createRefreshControl {
    UILabel *pullLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 80.0)];
    pullLabel.backgroundColor = [UIColor clearColor];
    pullLabel.textColor = [UIColor lightGrayColor];
    pullLabel.textAlignment = NSTextAlignmentCenter;
    
    _refreshControler = [[RNPullToActionControl alloc] initWithView:pullLabel];
    __weak typeof(self) weakSelf = self;
    __weak typeof(pullLabel) weakLabel = pullLabel;
    [self.collectionView addSubview:_refreshControler];
    _refreshControler.startPullActionBlock = ^{
        weakLabel.text = @"Pull to refresh";
    };
    _refreshControler.willStartLoadingBlock = ^{
        weakLabel.text = @"Loading...";
    };
    _refreshControler.startLoadingBlock = ^{
        [weakSelf loadMedia];
    };
    _refreshControler.pullToActionBlock = ^(UIView *activeView, CGPoint offset) {
        
    };
}

- (void)loadMedia {
    BOOL isSessionValid = [self.instagramEngine isSessionValid];
    [self setTitle: (isSessionValid) ? @"My Feed" : @"Popular"];
    [self.loader reloadMediaData];
    [self.collectionView reloadData];
}

- (void)userTapped:(id)sender {
    UserViewController *userVC = [[UserViewController alloc] init];
    [self.navigationController pushViewController:userVC animated:YES];
}

- (void)mediaDataUpdated:(NSNotification *)notification {
    NSUInteger offset = [self.collectionView numberOfItemsInSection:0];
    NSInteger count = [self.loader.mediaArray count] - offset;
    NSMutableArray *ipArray = [NSMutableArray array];
    if (count > 0) {
        for (NSInteger i = 0; i < count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:offset + i inSection:0];
            [ipArray addObject:indexPath];
        }
        [self.collectionView insertItemsAtIndexPaths:ipArray];
    } else {
        [self.collectionView reloadData];
    }
    
    if (_refreshControler.refreshing) {
        [_refreshControler endRefreshing];
    }
}

#pragma mark - User Authenticated Notification -


- (void)userAuthenticationChanged:(NSNotification *)notification {
    [self loadMedia];
}

#pragma mark - UICollectionViewDataSource Methods -


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.loader.mediaArray.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CPCELL" forIndexPath:indexPath];
    InstagramMedia *media = self.loader.mediaArray[indexPath.row];
    [cell setImageUrl:media.thumbnailURL];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DetailViewController *detailVc = [[DetailViewController alloc] init];
    detailVc.itemIndex = indexPath.row;
    [self.navigationController pushViewController:detailVc animated:YES];
}

- (void)updateCollectionViewLayout {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    CGFloat size = floor((CGRectGetWidth(self.collectionView.bounds)-1) / kNumberOfCellsInARow);
    layout.itemSize = CGSizeMake(size, size);
}

#pragma mark - UIScrollViewDelegate Methods -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y > -scrollView.contentInset.top &&
        scrollView.contentOffset.y > scrollView.contentSize.height - 2 * scrollView.bounds.size.height) {
        [self.loader loadMoreIfPossibleCount:kFetchItemsCount];
    }
}
@end

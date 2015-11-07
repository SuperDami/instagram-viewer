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
#import "LoginViewController.h"
#import "IVLoader.h"

#define kNumberOfCellsInARow 3
#define kFetchItemsCount 30
@interface MainViewerController ()
@property (nonatomic, weak) InstagramEngine *instagramEngine;
@property (nonatomic, weak) IVLoader *loader;
@end

@implementation MainViewerController

- (instancetype)init {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setMinimumInteritemSpacing:0.0f];
    [layout setMinimumLineSpacing:0.0f];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    if (self = [super initWithCollectionViewLayout:layout]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleDone target:self action:@selector(loginTapped:)];
    
    [self loadMedia];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadMedia {
    BOOL isSessionValid = [self.instagramEngine isSessionValid];
    [self setTitle: (isSessionValid) ? @"My Feed" : @"Popular Media"];
    [self.navigationItem.leftBarButtonItem setTitle: (isSessionValid) ? @"Log out" : @"Log in"];
    [self.loader reloadMediaData];
    [self.collectionView reloadData];
}

/**
 Invoked when user taps the left navigation item.
 @discussion Either directs to the Login ViewController or logs out.
 */
- (void)loginTapped:(id)sender {
    if (![self.instagramEngine isSessionValid]) {
        LoginViewController *loginNavigationViewController = [[LoginViewController alloc] init];
        UINavigationController *navVc = [[UINavigationController alloc] initWithRootViewController:loginNavigationViewController];
        [self presentViewController:navVc animated:YES completion:nil];
    }
    else
    {
        [self.instagramEngine logout];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"InstagramKit" message:@"You are now logged out." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alert show];
    }
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
    if (self.collectionView.contentOffset.y > self.collectionView.contentSize.height - 2 * self.collectionView.bounds.size.height) {
        [self.loader loadMoreIfPossibleCount:kFetchItemsCount];
    }
}
@end

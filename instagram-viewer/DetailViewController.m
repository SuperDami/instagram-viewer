//
//  DetailViewController.m
//  instagram-viewer
//
//  Created by chen zhejun on 11/7/15.
//  Copyright © 2015 superdami. All rights reserved.
//

#import "DetailViewController.h"
#import "DetailCell.h"
#import "InstagramKit.h"
#import "IVLoader.h"

#define kFetchItemsCount 10
@interface DetailViewController() <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak)InstagramEngine *instagramEngine;
@property (nonatomic, weak)IVLoader *loader;
@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.instagramEngine = [InstagramEngine sharedEngine];
    self.loader = [IVLoader shareInstance];
    
    [self.tableView registerClass:[DetailCell class] forCellReuseIdentifier:NSStringFromClass([DetailCell class])];
    [self.tableView reloadData];
    if (_itemIndex < [_loader.mediaArray count]) {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:_itemIndex inSection:0];
        [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaDataUpdated:)
                                                 name:IVLoaderMediaDataUpdated
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)mediaDataUpdated:(NSNotification *)noti {
    NSUInteger offset = [self.tableView numberOfRowsInSection:0];
    NSInteger count = [self.loader.mediaArray count] - offset;
    NSMutableArray *ipArray = [NSMutableArray array];
    if (count > 0) {
        for (NSInteger i = 0; i < count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:offset + i inSection:0];
            [ipArray addObject:indexPath];
        }
        [self.tableView insertRowsAtIndexPaths:ipArray withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDelegate Methods -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.loader.mediaArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    InstagramMedia *media = [self.loader.mediaArray objectAtIndex:indexPath.row];
    return [DetailCell cellHeightWithScreenWidth:self.view.bounds.size.width media:media];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DetailCell class]) forIndexPath:indexPath];
    cell.media = self.loader.mediaArray[indexPath.row];
    return cell;
}

#pragma mark - UIScrollViewDelegate Methods -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSArray *array = [self.tableView visibleCells];
    for (DetailCell *cell in array) {
        CGFloat middle = self.tableView.contentOffset.y + self.tableView.bounds.size.height / 2.0;
        if (CGRectGetMinY(cell.frame) < middle && middle < CGRectGetMaxY(cell.frame)) {
            [self setTitle:[NSString stringWithFormat:@"@%@", cell.media.user.username]];
            break;
        }
    }
    
    if (self.tableView.contentOffset.y > self.tableView.contentSize.height - 2 * self.tableView.bounds.size.height) {
        [self.loader loadMoreIfPossibleCount:kFetchItemsCount];
    }
}
@end

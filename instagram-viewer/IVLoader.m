//
//  IVLoader.m
//  instagram-viewer
//
//  Created by chen zhejun on 11/7/15.
//  Copyright © 2015 superdami. All rights reserved.
//

#import "IVLoader.h"
#import "InstagramKit.h"

@interface IVLoader()
@property (nonatomic, weak) InstagramEngine *instagramEngine;
@property (nonatomic, strong) InstagramPaginationInfo *currentPaginationInfo;
@end

@implementation IVLoader


+ (instancetype)shareInstance {
    static IVLoader *_shareInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _shareInstance = [[IVLoader alloc] init];
    });
    return _shareInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isLoading = NO;
        _hasMore = YES;
        _instagramEngine = [InstagramEngine sharedEngine];
        _mediaArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)reloadMediaData {
    _currentPaginationInfo = nil;
    _hasMore = YES;
    [_mediaArray removeAllObjects];
    
    if (_instagramEngine.isSessionValid) {
        [self loadMoreFeedCount:30];
    } else {
        [self loadPopular];
    }
}

- (void)loadMoreIfPossibleCount:(NSUInteger)count {
    if ([self.instagramEngine isSessionValid] && !self.isLoading && self.hasMore) {
        [self loadMoreFeedCount:count];
    }
}

- (void)loadMoreFeedCount:(NSUInteger)count {
    self.isLoading = YES;
    __weak typeof(self) weakMe = self;
    [self.instagramEngine getSelfFeedWithCount:count
                                         maxId:self.currentPaginationInfo.nextMaxId
                                       success:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
                                           weakMe.hasMore = [media count] > 0;
                                           weakMe.isLoading = NO;
                                           weakMe.currentPaginationInfo = paginationInfo;
                                           [weakMe.mediaArray addObjectsFromArray:media];
                                           [[NSNotificationCenter defaultCenter] postNotificationName:IVLoaderMediaDataUpdated object:nil];
                                       }
                                       failure:^(NSError *error, NSInteger statusCode) {
                                           weakMe.hasMore = NO;
                                           weakMe.isLoading = NO;
                                           weakMe.currentPaginationInfo = nil;
                                       }];
}

- (void)loadPopular
{
    _isLoading = YES;
    _hasMore = NO;
    __weak typeof(self) weakMe = self;
    [self.instagramEngine getPopularMediaWithSuccess: ^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
        weakMe.isLoading = NO;
        weakMe.currentPaginationInfo = paginationInfo;
        [_mediaArray addObjectsFromArray:media];
        [[NSNotificationCenter defaultCenter] postNotificationName:IVLoaderMediaDataUpdated object:nil];

    } failure: ^(NSError *error, NSInteger statusCode) {
        weakMe.isLoading = NO;
    }];
}
@end

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
@property (nonatomic, assign) NSInteger currentDataType;
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

- (void)prepareForReload {
    _currentPaginationInfo = nil;
    _hasMore = YES;
    [_mediaArray removeAllObjects];
}

- (void)reloadMediaData {
    [self prepareForReload];
    if (_instagramEngine.isSessionValid) {
        [self loadMoreType:1 count:30];
    } else {
        [self loadPopular];
    }
}

- (void)reloadUserLikes {
    [self prepareForReload];
    if (_instagramEngine.isSessionValid) {
        [self loadMoreType:2 count:30];
    }
}

- (void)reloadUserPosts {
    [self prepareForReload];
    if (_instagramEngine.isSessionValid) {
        [self loadMoreType:3 count:30];
    }
}

- (void)loadMoreIfPossibleCount:(NSUInteger)count {
    if ([self.instagramEngine isSessionValid] && !self.isLoading && self.hasMore && self.currentPaginationInfo) {
        [self loadMoreType:_currentDataType count:count];
    }
}

- (void)loadMoreType:(NSInteger)type count:(NSUInteger)count {
    self.isLoading = YES;
    NSLog(@"loadMore");

    NSString *notificationEvent;
    if (type == 1) {
        notificationEvent = IVLoaderMediaDataUpdated;
    } else if (type == 2) {
        notificationEvent = IVLoaderUserDataUpdated;
    } else if (type == 3) {
        notificationEvent = IVLoaderUserDataUpdated;
    }
    _currentDataType = type;
    
    __weak typeof(self) weakMe = self;
    __weak typeof(notificationEvent) weakNotiEvent = notificationEvent;
    InstagramMediaBlock successBlock = ^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
        weakMe.hasMore = [media count] > 0;
        weakMe.isLoading = NO;
        weakMe.currentPaginationInfo = paginationInfo;
        [weakMe.mediaArray addObjectsFromArray:media];
        [[NSNotificationCenter defaultCenter] postNotificationName:weakNotiEvent object:nil];
    };
    
    InstagramFailureBlock failureBlock = ^(NSError *error, NSInteger statusCode) {
        weakMe.hasMore = NO;
        weakMe.isLoading = NO;
    };
    
    if (type == 1) {
        [self.instagramEngine getSelfFeedWithCount:count
                                             maxId:self.currentPaginationInfo.nextMaxId
                                           success:successBlock
                                           failure:failureBlock];
    } else if (type == 2) {
        [self.instagramEngine getMediaLikedBySelfWithCount:count
                                                     maxId:self.currentPaginationInfo.nextMaxId
                                                   success:successBlock failure:failureBlock];
    } else if (type == 3) {
        [self.instagramEngine getMediaForUser:@"self"
                                        count:count
                                        maxId:self.currentPaginationInfo.nextMaxId
                                  withSuccess:successBlock
                                      failure:failureBlock];
    }
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

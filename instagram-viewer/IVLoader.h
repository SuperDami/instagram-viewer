//
//  IVLoader.h
//  instagram-viewer
//
//  Created by chen zhejun on 11/7/15.
//  Copyright © 2015 superdami. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *IVLoaderMediaDataUpdated = @"KIVLoaderNotificationMediaDataUpdated";
static NSString *IVLoaderUserDataUpdated = @"KIVLoaderUserDataUpdated";

@interface IVLoader : NSObject
@property(nonatomic, assign)BOOL isLoading;
@property(nonatomic, assign)BOOL hasMore;
@property(nonatomic, readonly)NSMutableArray *mediaArray;

+ (instancetype)shareInstance;
- (void)reloadMediaData;
- (void)reloadUserLikes;
- (void)reloadUserPosts;
- (void)loadMoreIfPossibleCount:(NSUInteger)count;
@end

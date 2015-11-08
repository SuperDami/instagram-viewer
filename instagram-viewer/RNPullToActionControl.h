//
//  RNPullToActionControl.h
//  WindowShop
//
//  Created by Chen Zhejun on 2015/01/27.
//  Copyright (c) 2015年 www.xiaotaojiang.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RNPullToActionObserverBlock)(UIView *activeView, CGPoint offset);
typedef void(^RNPullToActionStatusBlock)();

@interface RNPullToActionControl : UIControl <UIGestureRecognizerDelegate>
@property (nonatomic, readonly) BOOL refreshing;
@property (nonatomic, assign) CGFloat maxActionFireSpeed;
@property (nonatomic, assign) CGFloat pullHeight;
@property (nonatomic, strong) UIView *activeView;
@property (nonatomic, readonly) CGPoint offset;
@property (nonatomic, strong) RNPullToActionObserverBlock pullToActionBlock;
@property (nonatomic, strong) RNPullToActionStatusBlock startPullActionBlock;
@property (nonatomic, strong) RNPullToActionStatusBlock willStartLoadingBlock;
@property (nonatomic, strong) RNPullToActionStatusBlock startLoadingBlock;
@property (nonatomic, strong) RNPullToActionStatusBlock cancelLoadingBlock;

- (instancetype)initWithView:(UIView *)view;
- (void)beginRefreshing;
- (void)endRefreshing;
- (void)endRefreshingWithCompletionBlock:(void (^)(void))block;
@end

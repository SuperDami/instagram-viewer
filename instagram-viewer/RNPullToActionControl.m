//
//  RNPullToActionControl.m
//  WindowShop
//
//  Created by Chen Zhejun on 2015/01/27.
//  Copyright (c) 2015年 www.xiaotaojiang.com. All rights reserved.
//

#import "RNPullToActionControl.h"

@interface RNPullToActionControl ()
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@end

@implementation RNPullToActionControl {
    BOOL _isRefreshing;
    CGFloat _lastSpeed;
    UIEdgeInsets _originalEdgeInsets;
}

- (instancetype)initWithView:(UIView *)view {
    self = [super init];
    
    if (self) {
        _activeView = view;
        _pullHeight = view.frame.size.height;
        _activeView.frame = view.bounds;
        [self addSubview:_activeView];

        _maxActionFireSpeed = 500.0f;
        
        self.frame = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, _pullHeight);
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor clearColor];
        
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        _panGestureRecognizer.delegate = self;
    }
    return self;
}

- (void)dealloc {
    [self.superview removeGestureRecognizer:_panGestureRecognizer];
    [self.superview removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview && [newSuperview isEqual:self.superview]) return;
    
    // Clean old stuffs
    if (self.superview) [self.superview removeGestureRecognizer:_panGestureRecognizer];
    [self.superview removeObserver:self forKeyPath:@"contentOffset"];
    
    if (!newSuperview || ![newSuperview isKindOfClass:[UIScrollView class]]) return;
    
    __weak UIScrollView *scrollView = (UIScrollView *)newSuperview;
    scrollView.alwaysBounceVertical = YES;
    [self relayoutMe:scrollView];
    
    [newSuperview addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionPrior | NSKeyValueObservingOptionNew context:NULL];
    [newSuperview addGestureRecognizer:_panGestureRecognizer];
}

- (void)relayoutMe:(UIScrollView *)superview {
    if (![superview isKindOfClass:[UIScrollView class]]) return;
    
    CGRect frame = self.frame;
    frame.size.width = superview.frame.size.width;
    frame.origin.y = -_pullHeight;
    frame.size.height = _pullHeight;
    self.frame = frame;
}

- (void)beginRefreshing {
    if (_isRefreshing) {
        return;
    }
    if (![self.superview isKindOfClass:[UIScrollView class]]) {
        return;
    }
    _isRefreshing = YES;
    if (_willStartLoadingBlock) {
        _willStartLoadingBlock();
    }
    UIScrollView *scrollView = (UIScrollView *)self.superview;
    UIEdgeInsets edgeInsets = scrollView.contentInset;
    _originalEdgeInsets = edgeInsets;
    
    edgeInsets.top += self.frame.size.height;
    [UIView animateWithDuration:0.2 animations:^{
        scrollView.contentInset = edgeInsets;
    } completion:^(BOOL finished) {
        if (_startLoadingBlock) {
            _startLoadingBlock();
        }
        [self performSelector:@selector(endRefreshing) withObject:nil afterDelay:5.0];
    }];
}

- (void)endRefreshing {
    [self endRefreshingWithCompletionBlock:nil];
}

- (void)endRefreshingWithCompletionBlock:(void (^)(void))block {
    if (!_isRefreshing) {
        return;
    }
    if (![self.superview isKindOfClass:[UIScrollView class]]) {
        _isRefreshing = NO;
        return;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        _activeView.alpha = 1.0;
        ((UIScrollView *)self.superview).contentInset = _originalEdgeInsets;
    } completion:^(BOOL finished) {
        if (block) block();
        _isRefreshing = NO;
    }];
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)gestureRecognizer {
    if (!self.enabled || _isRefreshing || ![gestureRecognizer isEqual:_panGestureRecognizer]) return;
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if (_startPullActionBlock) {
            _startPullActionBlock();
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        _lastSpeed = [gestureRecognizer velocityInView:self].y;
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (self.offset.y >= 0) {
            if (self.offset.y >= self.frame.size.height) {
                [self beginRefreshing];
            }
            else {
                if (_cancelLoadingBlock) {
                    _cancelLoadingBlock();
                }
            }
        }
    }
}

- (BOOL)refreshing {
    return _isRefreshing;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([change objectForKey:@"new"]) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        CGPoint offset = [[change objectForKey:@"new"] CGPointValue];
        offset.y += scrollView.contentInset.top;
        offset.y = -offset.y;
        _offset = offset;
        
        if (!_isRefreshing) {
//            _activeView.alpha = offset.y < 0.0f ? 0.0f : MIN(((offset.y) / _pullHeight), 1.0f);
        }
        
        if (_offset.y >= 0) {
            if (!_isRefreshing && _pullToActionBlock) {
                _pullToActionBlock(_activeView, offset);
            }
        }
    }
}

#pragma mark - UIGestureRecognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
@end

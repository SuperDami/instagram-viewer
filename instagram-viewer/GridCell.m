//
//  GridCell.h
//  instagram-viewer
//
//  Created by chen zhejun on 11/7/15.
//  Copyright © 2015 superdami. All rights reserved.
//

#import "GridCell.h"
#import "UIImageView+AFNetworking.h"

@interface GridCell ()

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation GridCell

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (void)setImageUrl:(NSURL *)imageURL
{
    __weak typeof(self) weakMe = self;
    [self.imageView setImageWithURLRequest:[[NSURLRequest alloc] initWithURL:imageURL] placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        weakMe.imageView.image = image;
        [UIView animateWithDuration:0.15 animations:^{
            weakMe.imageView.alpha = 1.0;
        }];
    } failure:nil];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.imageView setImage:nil];
    self.imageView.alpha = 0.0;
}

@end

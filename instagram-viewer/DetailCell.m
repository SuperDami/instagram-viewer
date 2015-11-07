//
//  DetailCell.m
//  instagram-viewer
//
//  Created by chen zhejun on 11/7/15.
//  Copyright © 2015 superdami. All rights reserved.
//

#import "DetailCell.h"
#import "UIImageView+AFNetworking.h"
#import "InstagramKit.h"
#import "CommentLabel.h"

@interface DetailCell()
@property (nonatomic)UIImageView *contentImageView;
@property (nonatomic)CommentLabel *label;
@end

@implementation DetailCell {
    UIView *_line;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _contentImageView = [[UIImageView alloc] init];
        _contentImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_contentImageView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _label = [[CommentLabel alloc] init];
        _label.numberOfLines = 0;
        [self.contentView addSubview:_label];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat height = [[self class] imgHeightWith:self.bounds.size.width media:_media];
    _contentImageView.frame = CGRectMake(0.0, 0.0, self.bounds.size.width, height);
    
    height = [[self class] heightWithArrtString:_label.attributedText width:self.bounds.size.width - 20.0];
    _label.frame = CGRectMake(10.0, CGRectGetMaxY(_contentImageView.frame), self.bounds.size.width - 20.0, height);    
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _label.attributedText = nil;
    _contentImageView.image = nil;
    _contentImageView.alpha = 0.0;
}

- (void)setMedia:(InstagramMedia *)media {
    _media = media;
    _label.comment = media.caption;
    
    __weak typeof(self) weakMe = self;
    [self.contentImageView setImageWithURLRequest:[NSURLRequest requestWithURL:media.standardResolutionImageURL] placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        weakMe.contentImageView.image = image;
        [UIView animateWithDuration:0.2 animations:^{
            weakMe.contentImageView.alpha = 1.0;
        }];
    } failure:nil];
}

+ (CGFloat)cellHeightWithScreenWidth:(CGFloat)width media:(InstagramMedia *)media {
    NSString *username = media.caption.user.username;
    NSString *text = media.caption.text;
    
    NSMutableAttributedString *str = [CommentLabel commentAttrStringWithName:username text:text];
    return [[self class] imgHeightWith:width media:media] + [[self class] heightWithArrtString:str width:width - 20.0] + 10.0;
}

+ (CGFloat)imgHeightWith:(CGFloat)width media:(InstagramMedia *)media {
    CGSize imgSize = media.standardResolutionImageFrameSize;
    return (CGFloat)ceil(width / imgSize.width * imgSize.height);
}

+ (CGFloat)heightWithArrtString:(NSAttributedString *)str width:(CGFloat)width {
    if (str) {
        NSStringDrawingOptions options  = NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading;
        CGRect rect = [str boundingRectWithSize:CGSizeMake(width, 0) options:options context:nil];
        return MIN((CGFloat)(ceil(rect.size.height) + 4), 200.0);
    }
    return 0.0;
}
@end
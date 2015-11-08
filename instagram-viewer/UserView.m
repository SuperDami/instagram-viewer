//
//  UserView.m
//  instagram-viewer
//
//  Created by chen zhejun on 11/8/15.
//  Copyright © 2015 superdami. All rights reserved.
//

#import "InstagramUser.h"
#import "UserView.h"
#import "UIImageView+AFNetworking.h"

@implementation UserView {
    UIImageView *_avatarImgView;
    UILabel *_postLabel;
    UILabel *_follower;
    UILabel *_following;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _avatarImgView = [[UIImageView alloc] init];
        [self addSubview:_avatarImgView];
        [_avatarImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@80.0);
            make.height.equalTo(@80.0);
            make.centerX.equalTo(self);
            make.top.equalTo(self.mas_topMargin).offset(40.0);
        }];
        _avatarImgView.layer.borderWidth = 0.5;
        _avatarImgView.layer.cornerRadius = 40.0;
        _avatarImgView.layer.borderColor = [UIColor grayColor].CGColor;
        _avatarImgView.clipsToBounds = YES;
        
        _postLabel = [self createLabel];
        _follower = [self createLabel];
        _following = [self createLabel];
        
        [_follower mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_avatarImgView.mas_bottom).offset(20.0);
            make.width.equalTo(@80.0);
            make.height.equalTo(@60.0);
            make.centerX.equalTo(self);
        }];
        
        [_postLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_follower);
            make.size.equalTo(_follower);
            make.trailing.equalTo(_follower.mas_leading);
        }];
        
        [_following mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_follower);
            make.size.equalTo(_follower);
            make.leading.equalTo(_follower.mas_trailing);
        }];
    }
    return self;
}

- (UILabel *)createLabel {
    UILabel *label = [[UILabel alloc] init];
    [self addSubview:label];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 2;
    return label;
}

- (void)setUser:(InstagramUser *)user {
    _user = user;
    if (_user) {
        [_avatarImgView setImageWithURL:user.profilePictureURL];
        _postLabel.attributedText = [[self class] attrStringWithName:@"post" text:[NSString stringWithFormat:@"%lu", user.mediaCount]];
        _follower.attributedText = [[self class] attrStringWithName:@"follower" text:[NSString stringWithFormat:@"%lu", user.followedByCount]];
        _following.attributedText = [[self class] attrStringWithName:@"following" text:[NSString stringWithFormat:@"%lu", user.followsCount]];
    } else {
        _avatarImgView.image = nil;
        _postLabel.attributedText = [[self class] attrStringWithName:@"post" text:@"0"];
        _follower.attributedText = [[self class] attrStringWithName:@"follower" text:@"0"];
        _following.attributedText = [[self class] attrStringWithName:@"following" text:@"0"];
    }
}

+ (NSMutableAttributedString *)attrStringWithName:(NSString *)title text:(NSString *)text {
    NSString *oriStr = [[text stringByAppendingString:@"\n"] stringByAppendingString:title];
    if (oriStr) {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:oriStr];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0, [text length])];
        [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0] range:NSMakeRange(0, [text length])];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor]range:NSMakeRange([text length] + 1, [title length])];
        [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:14.0] range:NSMakeRange([text length] + 1, [title length])];
        return str;
    }
    return nil;
}
@end

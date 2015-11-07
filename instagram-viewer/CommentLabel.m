//
//  CommentLabel.m
//  instagram-viewer
//
//  Created by chen zhejun on 11/8/15.
//  Copyright © 2015 superdami. All rights reserved.
//

#import "CommentLabel.h"
#import "InstagramKit.h"

@implementation CommentLabel

- (void)setComment:(InstagramComment *)comment {
    _comment = comment;
    NSString *username = comment.user.username;
    NSString *text = comment.text;
    self.attributedText = [[self class] commentAttrStringWithName:username text:text];
}

+ (NSMutableAttributedString *)commentAttrStringWithName:(NSString *)username text:(NSString *)text {
    NSString *oriStr = [[username stringByAppendingString:@" "] stringByAppendingString:text];
    if (oriStr) {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:oriStr];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:67.0 / 255.0 green:115.0 / 255.0 blue:161.0 / 255.0 alpha:1.0] range:NSMakeRange(0, [username length])];
        [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0] range:NSMakeRange(0, [username length])];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor]range:NSMakeRange([username length] + 1, [text length])];
        return str;
    }
    return nil;
}
@end

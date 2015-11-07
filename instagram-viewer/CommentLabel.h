//
//  CommentLabel.h
//  instagram-viewer
//
//  Created by chen zhejun on 11/8/15.
//  Copyright © 2015 superdami. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InstagramComment;
@interface CommentLabel : UILabel
@property (nonatomic, strong)InstagramComment *comment;
+ (NSMutableAttributedString *)commentAttrStringWithName:(NSString *)username text:(NSString *)text;
@end

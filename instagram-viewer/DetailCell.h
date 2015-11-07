//
//  DetailCell.h
//  instagram-viewer
//
//  Created by chen zhejun on 11/7/15.
//  Copyright © 2015 superdami. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InstagramMedia;
@class InstagramComment;

@interface DetailCell : UITableViewCell
@property (nonatomic, strong)InstagramMedia *media;

+ (CGFloat)cellHeightWithScreenWidth:(CGFloat)width media:(InstagramMedia *)media;
@end

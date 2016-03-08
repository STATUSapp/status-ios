//
//  FullCaptionFeedCell.m
//  Status
//
//  Created by Cosmin Home on 06/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "FullCaptionFeedCell.h"
#import "STPost.h"

CGFloat const kBottomViewDefaultHeight = 50.f;

@interface FullCaptionFeedCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewConstr;

@end

@implementation FullCaptionFeedCell

-(void)configureCellWithPost:(STPost *)post{
    [super configureCellWithPost:post];
    
    UIFont *font = [UIFont fontWithName:@"ProximaNova-Regular" size:13.f];
    UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
    
    CGFloat textWidth = mainWindow.frame.size.width-kCaptionMargins;
    
    CGRect rect = [post.caption boundingRectWithSize:CGSizeMake(textWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    
    _bottomViewConstr.constant = kBottomViewDefaultHeight + rect.size.height;

    
}

@end

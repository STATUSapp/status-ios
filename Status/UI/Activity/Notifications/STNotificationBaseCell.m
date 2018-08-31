//
//  STNotificationBaseCell.m
//  Status
//
//  Created by Cosmin Andrus on 10/27/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STNotificationBaseCell.h"
#import "UIImageView+WebCache.h"
#import "NSDate+Additions.h"
@implementation STNotificationBaseCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)prepareForReuse{
    [super prepareForReuse];
    [_userImg sd_cancelCurrentAnimationImagesLoad];
}

- (NSAttributedString *)detailsStringForFullMessage:(NSString *)fullMessage
                                          actorName:(NSString *)actorName
                                   notificationDate:(NSDate *)notificationDate{
    NSString *timeString = [[NSDate notificationTimeIntervalSinceDate:notificationDate] lowercaseString];
    NSMutableAttributedString *detailsString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",fullMessage, timeString]];
    
    UIFont *nameFont = [UIFont fontWithName:@"ProximaNova-Bold" size:15.f];
    UIFont *messageFont = [UIFont fontWithName:@"ProximaNova-Regular" size:15.f];
    NSRange nameRange = [fullMessage rangeOfString:actorName];
    NSRange messageRange = NSMakeRange(0, detailsString.string.length);
    NSRange timeRange = [detailsString.string rangeOfString:timeString];
    
    if (nameRange.location != NSNotFound) {
        [detailsString addAttribute:NSFontAttributeName value:nameFont range:nameRange];
        messageRange.location = nameRange.location + nameRange.length;
        messageRange.length-=(nameRange.length + nameRange.location);
    }
    [detailsString addAttribute:NSFontAttributeName value:messageFont range:messageRange];
    
    if (timeRange.location != NSNotFound) {
        UIColor *grayColor = [UIColor colorWithRed:178.f/255.f
                                             green:178.f/255.f
                                              blue:178.f/255.f
                                             alpha:1.f];
        
        [detailsString addAttribute:NSForegroundColorAttributeName value:grayColor range:timeRange];
        [detailsString addAttribute:NSFontAttributeName value:messageFont range:timeRange];
        
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 2.f;
    [detailsString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, detailsString.string.length)];
    
    return detailsString;
}
@end

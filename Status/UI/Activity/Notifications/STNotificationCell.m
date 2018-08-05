//
//  STNotificationCell.m
//  Status
//
//  Created by Cosmin Andrus on 3/5/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STNotificationCell.h"
#import "UIImageView+TouchesEffects.h"
#import "UIImageView+WebCache.h"
#import "STNotificationObj.h"
#import "UIImageView+Mask.h"
#import "NSDate+Additions.h"

@interface STNotificationCell()

@property (weak, nonatomic) IBOutlet UIImageView *postImg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightImageWidthConstraint;

@end

@implementation STNotificationCell

- (STNotificationRegionType)regionForPointOfTap:(CGPoint)pointOfTap{
    
    if (CGRectContainsPoint(self.userImg.frame, pointOfTap)) {
        return STNotificationRegionTypeUserRelated;
    }
    
    if (CGRectContainsPoint(self.postImg.frame, pointOfTap)) {
        return STNotificationRegionTypePostRelated;
    }
    
    return STNotificationRegionTypeUserRelated;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(NSString *)reuseIdentifier{
    return @"notificationCell";
}

-(void)prepareForReuse{
    [super prepareForReuse];
    [_postImg sd_cancelCurrentAnimationImagesLoad];
}

-(void)configureWithNotificationObject:(STNotificationObj *)notificationObj{
    STNotificationType notificationType = notificationObj.type;
    UIImage *placeholder = [UIImage imageNamed:[notificationObj genderImageNameForGender:notificationObj.userGender]];
    __weak typeof (self) weakSelf = self;
    [self.userImg sd_setImageWithURL:[NSURL URLWithString:notificationObj.userThumbnail]
                          placeholderImage:placeholder
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     typeof (self) strongSelf = weakSelf;
                                     if (image) {
                                         [strongSelf.userImg maskImage:image];
                                     }
                                 }];
    if (notificationType!=STNotificationTypeGotFollowed) {
        [self.postImg sd_setImageWithURL:[NSURL URLWithString:notificationObj.postPhotoUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            typeof (self) strongSelf = weakSelf;
            if (image) {
                strongSelf.rightImageWidthConstraint.constant = 38.f;
            }
            else
                strongSelf.rightImageWidthConstraint.constant = 0.f;
            
        }];
    }
    else
    {
        self.rightImageWidthConstraint.constant = 38.f;
        UIImage *image = nil;
        if (notificationObj.followed == YES) {
            image = [UIImage imageNamed:@"following icon"];
        }
        else
            image = [UIImage imageNamed:@"follow icon"];
        
        self.postImg.image = image;
    }
    
    NSString *timeString = [[NSDate notificationTimeIntervalSinceDate:notificationObj.date] lowercaseString];
    NSMutableAttributedString *detailsString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",notificationObj.message, timeString]];
    
    UIFont *nameFont = [UIFont fontWithName:@"ProximaNova-Bold" size:15.f];
    UIFont *messageFont = [UIFont fontWithName:@"ProximaNova-Regular" size:15.f];
    NSRange nameRange = [notificationObj.message rangeOfString:notificationObj.userName];
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
    
    /*
     NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
     textAttachment.image = timeIconImage;
     NSAttributedString *timeIconString = [NSAttributedString attributedStringWithAttachment:textAttachment];
     
     [detailsString insertAttributedString:timeIconString atIndex:no.message.length + 1];
     */
    self.messageLbl.attributedText = detailsString;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end

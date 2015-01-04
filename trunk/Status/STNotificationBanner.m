//
//  STNotificationBanner.m
//  Status
//
//  Created by Cosmin Andrus on 09/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STNotificationBanner.h"
#import "UIImageView+WebCache.h"

@implementation STNotificationBanner

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)onClosePressed:(id)sender {
    [_delegate bannerPressedClose];
}
- (IBAction)onBannerTapped:(id)sender {
    [_delegate bannerTapped];
}
- (IBAction)onProfileImageTapped:(id)sender {
    [_delegate bannerProfileImageTapped];
}

- (void)configureBanner {
    [_profileImage sd_setImageWithURL:[NSURL URLWithString:_notificationInfo[@"photo"]] placeholderImage:[UIImage imageNamed:@"placeholder notifications screen"]];
    _messageText.attributedText = [[NSAttributedString alloc]initWithString:@""];
    _messageText.text = @"";
    NSMutableAttributedString *messageStr = [[NSMutableAttributedString alloc] initWithString:_notificationInfo[@"alert_message"]];
    UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:16.f];
//    NSUInteger nameLenght = [_notificationInfo[@"name"] length];
    NSRange nameRange = [_notificationInfo[@"alert_message"] rangeOfString:_notificationInfo[@"name"]];
//    [messageStr setAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(0, messageStr.length)];
    _messageText.textColor = [UIColor whiteColor];
    [messageStr setAttributes:@{NSFontAttributeName:font} range:nameRange];
    _messageText.attributedText = messageStr;
}

-(void)setUpWithNotificationInfo:(NSDictionary *)info{
    _notificationInfo = info;
    _notificationType = [_notificationInfo[@"notification_type"] integerValue];
    
    [self configureBanner];
}

@end

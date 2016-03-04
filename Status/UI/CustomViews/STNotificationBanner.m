//
//  STNotificationBanner.m
//  Status
//
//  Created by Cosmin Andrus on 09/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STNotificationBanner.h"
#import "UIImageView+WebCache.h"
#import "STImageCacheController.h"

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
    if (_notificationType == STNotificationTypeChatMessage) {
        [_delegate bannerTapped];
    }
    else
        [_delegate bannerProfileImageTapped];
}

- (void)configureBanner {
    NSString *urlString = _notificationInfo[@"photo"];
    if (urlString!=nil && [urlString rangeOfString:@"http"].location==NSNotFound) {
        urlString = [NSString stringWithFormat:@"%@%@",[CoreManager imageCacheService].photoDownloadBaseUrl, _notificationInfo[@"photo"]];
    }
    [_profileImage sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"placeholder notifications screen"]];
    _messageText.attributedText = [[NSAttributedString alloc]initWithString:@""];
    _messageText.text = @"";
    _messageText.textColor = [UIColor whiteColor];
    
    NSString *alertMessage = _notificationInfo[@"alert_message"];
    NSString *name = _notificationInfo[@"name"];
    NSMutableAttributedString *messageStr = [[NSMutableAttributedString alloc] initWithString:alertMessage];
    UIFont *font = [UIFont fontWithName:@"ProximaNova-Semibold" size:16.f];
    if (alertMessage && alertMessage.length > 0 && name && name.length > 0) {
        NSRange nameRange = [alertMessage rangeOfString:name];
        [messageStr setAttributes:@{NSFontAttributeName:font} range:nameRange];
        _messageText.attributedText = messageStr;
    }
}

-(void)setUpWithNotificationInfo:(NSDictionary *)info{
    _notificationInfo = info;
    _notificationType = [_notificationInfo[@"notification_type"] integerValue];
    
    [self configureBanner];
}

@end

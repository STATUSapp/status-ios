//
//  STNotificationBanner.h
//  Status
//
//  Created by Cosmin Andrus on 09/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STNotificationBannerDelegate <NSObject>

-(void)bannerPressedClose;
-(void)bannerTapped;
-(void)bannerProfileImageTapped;

@end

@interface STNotificationBanner : UIView
@property(nonatomic, weak) id <STNotificationBannerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *messageText;
@property (assign, nonatomic) STNotificationType notificationType;
@property (nonatomic, strong) NSDictionary *notificationInfo;

-(void)setUpWithNotificationInfo:(NSDictionary *)info;
@end

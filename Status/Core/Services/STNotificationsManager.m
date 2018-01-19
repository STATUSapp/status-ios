//
//  STNotificationsManager.m
//  Status
//
//  Created by Cosmin Andrus on 09/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STNotificationsManager.h"
#import "ContainerFeedVC.h"
#import "STChatController.h"
#import "STChatRoomViewController.h"
#import "STNetworkQueueManager.h"
#import "STNotificationsViewController.h"
#import "STNotificationBanner.h"
#import "STFacebookLoginController.h"
#import "STNotificationsViewController.h"
#import "STImageCacheController.h"

#import "STListUser.h"
#import "STNavigationService.h"
#import "STLocalNotificationService.h"
#import "STGetNotificationsCountRequest.h"
#import "STUnseenPostsCountRequest.h"
#import "BadgeService.h"

@interface STNotificationsManager()<STNotificationBannerDelegate>{
    NSDictionary *_lastNotification;
    NSTimer *_dismissTimer;
    STNotificationBanner *_currentBanner;
}

@end


@implementation STNotificationsManager

-(instancetype)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLoggedIn) name:kNotificationUserDidLoggedIn object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLoggedOut) name:kNotificationUserDidLoggedOut object:nil];
    }
    
    return self;
}

-(void)dealloc{
    [_dismissTimer invalidate];
    _dismissTimer = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)requestRemoteNotificationAccess{
    UIUserNotificationSettings *settings =
    [UIUserNotificationSettings
     settingsForTypes: (UIUserNotificationTypeBadge |
                        UIUserNotificationTypeSound |
                        UIUserNotificationTypeAlert)
     categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    
}

-(void) handleNotification:(NSDictionary *) notif{
    if (notif == nil) {
        return;
    }
    
    if (![CoreManager loggedIn] || [STNavigationService appTabBar] == nil) {
        //wait for the login to be performed and after handle the notification
        _lastNotification = notif;
        return;
    }
    if ([notif[@"user_info"][@"notification_type"] integerValue] == STNotificationTypeChatMessage) {
        return;
        _lastNotification = nil;
        NSDictionary *userInfo = notif[@"user_info"];
        STListUser *lu = [STListUser new];
        lu.uuid = userInfo[@"user_id"];        
        if (lu.uuid == nil) {
            NSLog(@"Error from notification: user_id = nil");
            return;
        }
        
        STChatRoomViewController *viewController = [STChatRoomViewController roomWithUser:lu];
        [[CoreManager navigationService] goToChat];
        [[CoreManager navigationService] pushViewController:viewController
                                            inTabbarAtIndex:STTabBarIndexActivity
                                        keepThecurrentStack:NO];
    }
    else
    {   _lastNotification = nil;
        [[CoreManager navigationService] goToNotifications];
    }
}

-(void)handleLastNotification{
    [self handleNotification:_lastNotification];
}

- (STNotificationBanner *)createBannerWithNotificationInfo:(NSMutableDictionary *)notificationDict {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"STNotificationBanner" owner:self options:nil];
    STNotificationBanner *banner = (STNotificationBanner*)[views firstObject];
    banner.delegate = self;
    [banner setUpWithNotificationInfo:notificationDict];
    return banner;
}

-(void)handleInAppNotification:(NSDictionary *)notification{
    [[CoreManager localNotificationService] postNotificationName:STNotificationsShouldBeReloaded object:nil userInfo:nil];
    
    NSMutableDictionary *notificationDict = [[NSMutableDictionary alloc] initWithDictionary:notification[@"user_info"]];
    STNotificationType notifType = [notificationDict[@"notification_type"] integerValue];
    if (notifType == STNotificationTypeLike ||
          notifType == STNotificationTypeUploaded /* ||
          notifType == STNotificationTypeChatMessage*/) {
        NSString *alertMesage = notification[@"aps"][@"alert"];
        
        if (alertMesage !=nil )
            notificationDict[@"alert_message"] = alertMesage;
        else
        {
            if (notifType == STNotificationTypeLike) {
                alertMesage = [NSString stringWithFormat:@"%@ likes your photo.", notificationDict[@"name"]];
            }
            else if (notifType == STNotificationTypeUploaded)
                alertMesage = [NSString stringWithFormat:@"%@ uploaded a new photo.", notificationDict[@"name"]];
            else
                alertMesage = @"";
            
            notificationDict[@"alert_message"] = alertMesage;
            
        }
        
        STNotificationBanner *banner;
        banner = [self createBannerWithNotificationInfo:notificationDict];
        [self showBanner:banner];
    }
}

-(void)handleInAppMessageNotification:(NSDictionary *)notification{
    NSMutableDictionary *notificationDict = [[NSMutableDictionary alloc] initWithDictionary:notification[@"notification_info"]];

    NSString *alertMesage = [NSString stringWithFormat:@"%@\n%@",notificationDict[@"name"],notification[@"message"]];

    if (alertMesage == nil) {
        return;
    }
    notificationDict[@"alert_message"] = alertMesage;
    notificationDict[@"notification_type"] = @(STNotificationTypeChatMessage);
    notificationDict[@"user_id"] = [CreateDataModelHelper validStringIdentifierFromValue:notification[@"userId"]];
    
    STNotificationBanner *banner;
    banner = [self createBannerWithNotificationInfo:notificationDict];
    [self showBanner:banner];
}

#pragma mark - Banner View

-(void)showBanner:(STNotificationBanner *)banner{
    [self removeBanner];
    UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
    
    //set the right width
    CGRect rect = banner.frame;
    rect.size.width = mainWindow.frame.size.width;
    rect.origin.y = -1 * rect.size.height;
    banner.frame = rect;
    
    [mainWindow addSubview:banner];
    
    rect.origin.y = 0;
    _currentBanner = banner;
    
    [UIView animateWithDuration:0.25 animations:^{
        _currentBanner.frame = rect;
        
    } completion:^(BOOL finished) {
        _dismissTimer = [NSTimer scheduledTimerWithTimeInterval:5.f target:self selector:@selector(dismissCurrentBanner) userInfo:nil repeats:NO];

    }];

}

- (void)removeBanner {
    [_currentBanner removeFromSuperview];
    _currentBanner = nil;
    [_dismissTimer invalidate];
    _dismissTimer = nil;
}

-(void)dismissCurrentBanner{
    CGRect rect = _currentBanner.frame;
    rect.origin.y = -rect.size.height;
    [UIView animateWithDuration:0.25 animations:^{
        _currentBanner.frame = rect;
        
    } completion:^(BOOL finished) {
        [self removeBanner];
    }];
    
}

#pragma mark STNotificationBannerDelegate

-(void)bannerTapped{
    NSLog(@"Banner pressed");
    STNotificationType notifType = _currentBanner.notificationType;
    switch (notifType) {
        case STNotificationTypeLike:
        {
            NSString *postID = _currentBanner.notificationInfo[@"post_id"];
            ContainerFeedVC *feedCVC = [ContainerFeedVC singleFeedControllerWithPostId:postID];
            
            [[CoreManager navigationService] pushViewController:feedCVC inTabbarAtIndex:STTabBarIndexHome keepThecurrentStack:NO];
        }
            break;
        case STNotificationTypeChatMessage:
        {
            /*
            STListUser *lu = [STListUser new];
            lu.uuid = [CreateDataModelHelper validStringIdentifierFromValue:_currentBanner.notificationInfo[@"user_id"]];
            lu.userName = _currentBanner.notificationInfo[@"name"];
            NSString *urlString = _currentBanner.notificationInfo[@"photo"];
            if ([urlString rangeOfString:@"http"].location==NSNotFound) {
                urlString = [NSString stringWithFormat:@"%@%@",[CoreManager imageCacheService].photoDownloadBaseUrl, _currentBanner.notificationInfo[@"photo"]];
            }
            lu.thumbnail = urlString;

            STChatRoomViewController *viewController = [STChatRoomViewController roomWithUser:lu];
            
            [[CoreManager navigationService] pushViewController:viewController inTabbarAtIndex:STTabBarIndexChat keepThecurrentStack:NO];
             */
        }
            break;
        case STNotificationTypeUploaded:
            [self bannerProfileImageTapped];
            break;
        default:
            break;
    }
    
    [self dismissCurrentBanner];
}

-(void)bannerProfileImageTapped{
    NSString * userId = nil;
    id userIdentifier = [_currentBanner.notificationInfo valueForKey:@"user_id"];
    if ([userIdentifier respondsToSelector:@selector(stringValue)]) {
        userId = [userIdentifier stringValue];
    }
    else
        userId = userIdentifier;
    
    ContainerFeedVC *feedCVC = [ContainerFeedVC galleryFeedControllerForUserId:userId andUserName:nil];
    [[CoreManager navigationService] pushViewController:feedCVC inTabbarAtIndex:STTabBarIndexHome keepThecurrentStack:NO];
    
    [self dismissCurrentBanner];
}

-(void)bannerPressedClose{
    [self dismissCurrentBanner];
}

- (void)userDidLoggedIn{
    [self handleLastNotification];
    [[CoreManager badgeService] startService];
}

- (void)userDidLoggedOut{
    [[CoreManager badgeService] stopService];
}

@end

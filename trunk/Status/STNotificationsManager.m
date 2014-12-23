//
//  STNotificationsManager.m
//  Status
//
//  Created by Cosmin Andrus on 09/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STNotificationsManager.h"
#import "STFlowTemplateViewController.h"
#import "STChatController.h"
#import "STChatRoomViewController.h"
#import "STNetworkQueueManager.h"
#import "STNotificationsViewController.h"
#import "STNotificationBanner.h"

@interface STNotificationsManager()<STNotificationBannerDelegate>{
    NSDictionary *_lastNotification;
    NSTimer *_dismissTimer;
    STNotificationBanner *_currentBanner;
}

@end

static STNotificationsManager *_sharedManager = nil;

@implementation STNotificationsManager
+ (STNotificationsManager *)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [STNotificationsManager new];
    });
    
    return _sharedManager;
}
- (UIViewController *)getCurrentViewController {
    UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
    
    UINavigationController *navController = (UINavigationController *)mainWindow.rootViewController;
    UIViewController *lastVC = [navController.viewControllers firstObject];
    return lastVC;
}

//TODO: test all those scenarios

-(void) handleNotification:(NSDictionary *) notif{
    if (notif == nil) {
        return;
    }
    UIViewController *lastVC = [self getCurrentViewController];

    if ([lastVC isKindOfClass:[STFlowTemplateViewController class]]) {
        
        if ([notif[@"user_info"][@"notification_type"] integerValue] == STNotificationTypeChatMessage) {
            if (![[STChatController sharedInstance] canChat]) {
                //wait for the chat authentication to be performed and after handle the notification
                _lastNotification = notif;
                return;
            }
            _lastNotification = nil;
            NSDictionary *userInfo = notif[@"user_info"];
            if (userInfo[@"user_id"] == nil) {
                NSLog(@"Error from notification: user_id = nil");
                return;
            }
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatScene" bundle:nil];
            STChatRoomViewController *viewController = (STChatRoomViewController *)[storyboard instantiateViewControllerWithIdentifier:@"chat_room"];
            viewController.userInfo = [NSMutableDictionary dictionaryWithDictionary:notif[@"user_info"]];
            [lastVC.navigationController pushViewController:viewController animated:YES];
        }
        else
        {
            if ([STNetworkQueueManager sharedManager].accessToken == nil) {
                //wait for the login to be performed and after handle the notification
                _lastNotification = notif;
                return;
            }
            _lastNotification = nil;
            [lastVC performSegueWithIdentifier:@"notifSegue" sender:nil];
        }
    }
}

-(void)handleLastNotification{
    [self handleNotification:_lastNotification];
}

-(void)handleInAppNotification:(NSDictionary *)notification{
    UIViewController *lastVC = [self getCurrentViewController];
    if ([lastVC isKindOfClass:[STNotificationsViewController class]]){
        [(STNotificationsViewController *)lastVC getNotificationsFromServer];
    }
    
    STNotificationType notifType = [notification[@"user_info"][@"notification_type"] integerValue];
    if (!(notifType == STNotificationTypeLike)) {
        return;
    }
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"STNotificationBanner" owner:self options:nil];
    STNotificationBanner *banner = (STNotificationBanner*)[views firstObject];
    banner.notificationType = notifType;
    banner.delegate = self;
    
    switch (notifType) {
        case STNotificationTypeLike:
            //TODO: modify banner for likes
            break;
        case STNotificationTypeChatMessage:
            //TODO: modify banner for messages
            break;
        case STNotificationTypeUploaded:
            //TODO: modify banner for uploaded photos
            break;
        default:
            break;
    }
    
    [self showBanner:banner];
}

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
        _dismissTimer = [NSTimer scheduledTimerWithTimeInterval:2.f target:self selector:@selector(dismissCurrentBanner) userInfo:nil repeats:NO];

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
            //TODO: add handler for likes
            break;
        case STNotificationTypeChatMessage:
            //TODO: add handler for messages
            break;
        case STNotificationTypeUploaded:
            //TODO: add handler for uploaded photos
            break;
        default:
            break;
    }
    
    [self dismissCurrentBanner];
}

-(void)bannerPressedClose{
    [self dismissCurrentBanner];
}
@end

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
#import "STFacebookLoginController.h"

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
    UIViewController *lastVC = [navController.viewControllers lastObject];
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

- (STNotificationBanner *)createBannerWithNotificationInfo:(NSMutableDictionary *)notificationDict {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"STNotificationBanner" owner:self options:nil];
    STNotificationBanner *banner = (STNotificationBanner*)[views firstObject];
    banner.delegate = self;
    [banner setUpWithNotificationInfo:notificationDict];
    return banner;
}

-(void)handleInAppNotification:(NSDictionary *)notification{
    UIViewController *lastVC = [self getCurrentViewController];
    if ([lastVC isKindOfClass:[STNotificationsViewController class]]){
        [(STNotificationsViewController *)lastVC getNotificationsFromServer];
    }
    NSMutableDictionary *notificationDict = [[NSMutableDictionary alloc] initWithDictionary:notification[@"user_info"]];
    STNotificationType notifType = [notificationDict[@"notification_type"] integerValue];
    if (!(notifType == STNotificationTypeLike ||
          notifType == STNotificationTypeUploaded ||
          notifType == STNotificationTypeChatMessage)) {
        return;
    }
    NSString *alertMesage = notification[@"aps"][@"alert"];
    
    if (alertMesage!=nil)
        notificationDict[@"alert_message"] = alertMesage;
    else
    {
        if (notifType == STNotificationTypeLike) {
            alertMesage = [NSString stringWithFormat:@"%@ likes your photo.", notificationDict[@"name"]];
        }
        else if (notifType == STNotificationTypeUploaded)
            alertMesage = [NSString stringWithFormat:@"%@ uploaded a new photo.", notificationDict[@"name"]];
        
        notificationDict[@"alert_message"] = alertMesage;

    }
    
    STNotificationBanner *banner;
    banner = [self createBannerWithNotificationInfo:notificationDict];
    [self showBanner:banner];
}

-(void)handleInAppMessageNotification:(NSDictionary *)notification{
    NSMutableDictionary *notificationDict = [[NSMutableDictionary alloc] initWithDictionary:notification[@"notification_info"]];

    NSString *alertMesage = [NSString stringWithFormat:@"%@\n%@",notificationDict[@"name"],notification[@"message"]];

    if (alertMesage == nil) {
        return;
    }
    notificationDict[@"alert_message"] = alertMesage;
    notificationDict[@"notification_type"] = @(STNotificationTypeChatMessage);
    notificationDict[@"user_id"] = notification[@"userId"];
    
    STNotificationBanner *banner;
    banner = [self createBannerWithNotificationInfo:notificationDict];
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

- (void)dissmissPresentedVCs:(UIViewController *)lastVC {
    while (lastVC.presentedViewController != nil) {
        [lastVC.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    }
}

-(void)bannerTapped{
    NSLog(@"Banner pressed");
    STNotificationType notifType = _currentBanner.notificationType;
    UIViewController *lastVC = [self getCurrentViewController];
    [self dissmissPresentedVCs:lastVC];
    switch (notifType) {
        case STNotificationTypeLike:
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            STFlowTemplateViewController *flowCtrl = [storyboard instantiateViewControllerWithIdentifier: @"flowTemplate"];
            flowCtrl.flowType = STFlowTypeSinglePost;
            flowCtrl.postID = _currentBanner.notificationInfo[@"post_id"];
            flowCtrl.userID = _currentBanner.notificationInfo[@"user_id"];
            flowCtrl.userName = _currentBanner.notificationInfo[@"name"];
            [lastVC.navigationController pushViewController:flowCtrl animated:YES];

        }
            break;
        case STNotificationTypeChatMessage:
        {
            NSMutableDictionary *selectedUserInfo = [NSMutableDictionary new];
            selectedUserInfo[@"user_id"] = _currentBanner.notificationInfo[@"user_id"];
            selectedUserInfo[@"user_name"] = _currentBanner.notificationInfo[@"name"];
            selectedUserInfo[@"small_photo_link"] = _currentBanner.notificationInfo[@"photo"];

            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatScene" bundle:nil];
            STChatRoomViewController *viewController = (STChatRoomViewController *)[storyboard instantiateViewControllerWithIdentifier:@"chat_room"];
            viewController.userInfo = [NSMutableDictionary dictionaryWithDictionary:selectedUserInfo];

            
            if ([lastVC isKindOfClass:[STChatRoomViewController class]]) {
                //replace this last room with the new one
                UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
                
                UINavigationController *navController = (UINavigationController *)mainWindow.rootViewController;

                NSMutableArray *vcs = [NSMutableArray arrayWithArray:navController.viewControllers];
                [vcs removeLastObject];
                [vcs addObject:viewController];
                
                [lastVC.navigationController setViewControllers:vcs];
                
            }
            else
                [lastVC.navigationController pushViewController:viewController animated:YES];

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
    UIViewController *lastVC = [self getCurrentViewController];
    [self dissmissPresentedVCs:lastVC];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    STFlowTemplateViewController *flowCtrl = [storyboard instantiateViewControllerWithIdentifier: @"flowTemplate"];
    flowCtrl.flowType = STFlowTypeUserProfile;
    id userId = [_currentBanner.notificationInfo valueForKey:@"user_id"];
    if ([userId respondsToSelector:@selector(stringValue)]) {
        flowCtrl.userID = [userId stringValue];
    }
    else
        flowCtrl.userID = userId;
    flowCtrl.userName = _currentBanner.notificationInfo[@"name"];
    if ([flowCtrl.userID isEqualToString:[STFacebookLoginController sharedInstance].currentUserId ]) {
        flowCtrl.flowType = STFlowTypeMyProfile;
    }
    [lastVC.navigationController pushViewController:flowCtrl animated:YES];
    
    [self dismissCurrentBanner];
}

-(void)bannerPressedClose{
    [self dismissCurrentBanner];
}
@end

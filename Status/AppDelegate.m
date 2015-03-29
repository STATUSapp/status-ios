//
//  AppDelegate.m
//  Status
//
//  Created by Andrus Cosmin on 16/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "STFlowTemplateViewController.h"
#import "STNetworkQueueManager.h"
#import "STConstants.h"
#import "STFacebookLoginController.h"
#import "STImageCacheController.h"
#import "STLocationManager.h"
#import "STIAPHelper.h"
#import "STChatRoomViewController.h"

#import <MobileAppTracker/MobileAppTracker.h>
#import <AdSupport/AdSupport.h>

#import "STInviteController.h"
#import "STChatController.h"
#import "STConversationsListViewController.h"
#import "STFacebookAlbumsViewController.h"

#import "STCoreDataManager.h"
#import <Crashlytics/Crashlytics.h>

#import "STSetAPNTokenRequest.h"
#import "STGetNotificationsCountRequest.h"
#import "STBaseRequest.h"
#import "STNotificationsManager.h"

#import "Appirater.h"

static NSString * const kSTNewInstallKey = @"kSTNewInstallKey";
@interface AppDelegate()<UIAlertViewDelegate>

@end

@implementation AppDelegate

- (void)setBadgeNumber:(NSInteger)badgeNumber{
    
    _badgeNumber = badgeNumber;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber];
    [[NSNotificationCenter defaultCenter] postNotificationName:STNotificationBadgeValueDidChanged object:nil];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [STIAPHelper sharedInstance];
    [FBLoginView class];
    [application setStatusBarHidden:YES];
    self.badgeNumber = application.applicationIconBadgeNumber;
    [[STNotificationsManager sharedManager] handleNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
    
    // setup Mobile App Tracker
    
    // Account Configuration info - must be set
    [MobileAppTracker initializeWithMATAdvertiserId:kMATAdvertiserID
                                   MATConversionKey:kMATConversionKey];
    
    // Used to pass us the IFA, enables highly accurate 1-to-1 attribution.
    // Required for many advertising networks.
    [MobileAppTracker setAppleAdvertisingIdentifier:[[ASIdentifierManager sharedManager] advertisingIdentifier]
                         advertisingTrackingEnabled:[[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]];
    
    NSString * newInstall = [[NSUserDefaults standardUserDefaults] objectForKey:kSTNewInstallKey];
    
    if (newInstall == nil) {
        [MobileAppTracker measureAction:@"install"];
        [[NSUserDefaults standardUserDefaults] setObject:kSTNewInstallKey forKey:kSTNewInstallKey];
    }
//    [Crashlytics startWithAPIKey:@"b4369a0a1dca4a6745a3905bf41aa6964c863da1"];
    [Crashlytics startWithAPIKey:@"93e0064668657d3332278aaa1ed765b8f48c6ad6"];
    [self cleanLocalDBIfNeeded];
    
    [Appirater setAppId:APP_STORE_ID];
    [Appirater setDaysUntilPrompt:7];
    [Appirater setUsesUntilPrompt:10];
    [Appirater setTimeBeforeReminding:2];
    
    [Appirater setCustomAlertTitle:@"Do you love Get STATUS?"];
    [Appirater setCustomAlertMessage:@"Please share the love by rating us 5 stars in the store."];
    [Appirater setCustomAlertRateButtonTitle:@"Rate us"];
    [Appirater setCustomAlertRateLaterButtonTitle:@"Maybe later"];
    [Appirater setCustomAlertCancelButtonTitle:@"No, thanks"];
    
    [Appirater appLaunched:YES];
    return YES;
}

-(void)cleanLocalDBIfNeeded{
    //we need this clenup from 1.0.7 to future versions because of the uuid parameter from messages
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *upgraded = [ud valueForKey:@"upgradeDBV1.0.7"];
    if (upgraded == nil) {
        [[STCoreDataManager sharedManager] cleanLocalDataBase];
        [ud setValue:@"YES" forKey:@"upgradeDBV1.0.7"];
        [ud synchronize];
    }
}
- (void)applicationWillResignActive:(UIApplication *)application
{
//    [STNetworkQueueManager sharedManager].isPerformLoginOrRegistration=FALSE;
    
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    NSMutableArray *stackVCs = [NSMutableArray arrayWithArray:navController.viewControllers];
    BOOL removed = NO;
    //TODO: add more clasess here, as needed
    while ([[stackVCs lastObject] isKindOfClass:[STChatRoomViewController class]] ||
           [[stackVCs lastObject] isKindOfClass:[STConversationsListViewController class]]) {
        removed = YES;
        [stackVCs removeLastObject];
    }
    if (removed == YES) {
        [navController setViewControllers:stackVCs];
    }
    [[STChatController sharedInstance] leaveCurrentRoom];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [NSObject cancelPreviousPerformRequestsWithTarget:[STLocationManager sharedInstance] selector:@selector(restartLocationManager) object:nil];
    [[STChatController sharedInstance] close];
    [[STCoreDataManager sharedManager] save];
    //[[STLocationManager sharedInstance] startLocationUpdates];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if ([[STInviteController sharedInstance] shouldInviteBeAvailable]) {
        [[STInviteController sharedInstance] callTheDelegate];
    }
    
    [FBAppCall handleDidBecomeActive];
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    STFlowTemplateViewController *viewController = (STFlowTemplateViewController *)[navController.viewControllers objectAtIndex:0];
    [viewController updateNotificationsNumber];
    [[STFacebookLoginController sharedInstance] loadTokenFromKeyChain];
    
    // MAT will not function without the measureSession call included
    [MobileAppTracker measureSession];
    
    [[STChatController sharedInstance] reconnect];
    [[STChatController sharedInstance] startReachabilityService];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[STChatController sharedInstance] close];
    [[STCoreDataManager sharedManager] save];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    [MobileAppTracker applicationDidOpenURL:[url absoluteString] sourceApplication:sourceApplication];

    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    return wasHandled;
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    //the best fail of Apple ever, why calling this extra delegate method?
    if (notificationSettings.types) {
        NSLog(@"User allowed notifications");
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }else{
        NSLog(@"User did not allow notifications");
        //TODO: show alert here?
    }
}

#endif

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
//#warning remove this
//    NSLog(@"APN Token --- %@", token);
//    [[[UIAlertView alloc] initWithTitle:@"Test" message:[NSString stringWithFormat:@"%@", token] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    if ([STNetworkQueueManager sharedManager].accessToken!=nil) {
        STRequestCompletionBlock completion = ^(id response, NSError *error){
            if ([response[@"status_code"] integerValue]==STWebservicesSuccesCod)  NSLog(@"APN Token set.");
            else  NSLog(@"APN token NOT set.");
        };
        [STSetAPNTokenRequest setAPNToken:token withCompletion:completion failure:nil];
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSLog(@"Notif: %@", userInfo);
    NSLog(@"App state: %lu", (unsigned long)application.applicationState);

    self.badgeNumber = [userInfo[@"aps"][@"badge"] integerValue];
    if (application.applicationState!=UIApplicationStateActive) {
        [[STNotificationsManager sharedManager] handleNotification:userInfo];

    }
    else
    {
//#warning remove this mockup
//        NSMutableDictionary *debugUserInfo = [NSMutableDictionary dictionaryWithDictionary:userInfo];
//        NSMutableDictionary *payloadUserInfo = [NSMutableDictionary dictionaryWithDictionary: debugUserInfo[@"user_info"]];
//        payloadUserInfo[@"name"] = @"Einstein";
//        payloadUserInfo[@"photo"] = @"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xfp1/v/t1.0-1/s200x200/10354686_10150004552801856_220367501106153455_n.jpg?oh=9dc41c83e9eea8ba96538c6b8ea6d16d&oe=550DCA50&__gda__=1426728006_926067ef0f35eed4118319b475d142bd";
//        payloadUserInfo[@"post_id"] = @(71);
//        payloadUserInfo[@"user_id"] = @(35);
//        debugUserInfo[@"user_info"] = payloadUserInfo;
//#ifdef DEBUG
//        [[STNotificationsManager sharedManager] handleInAppNotification:debugUserInfo];
//
//#else
        [[STNotificationsManager sharedManager] handleInAppNotification:userInfo];
//#endif
    }
}

-(void)checkForNotificationNumber{
    __weak AppDelegate *weakSelf = self;
    if ([STNetworkQueueManager sharedManager].accessToken != nil &&
        [STNetworkQueueManager sharedManager].accessToken.length > 0) {
        STRequestCompletionBlock completion = ^(id response, NSError *error){
            if ([response[@"status_code"] integerValue] ==STWebservicesSuccesCod) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.badgeNumber = [response[@"count"] integerValue];
                });
            }
        };
        [STGetNotificationsCountRequest getNotificationsCountWithCompletion:completion failure:nil];
    }
}

@end

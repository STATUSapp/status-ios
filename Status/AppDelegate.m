//
//  AppDelegate.m
//  Status
//
//  Created by Andrus Cosmin on 16/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "AppDelegate.h"
#import "STNetworkQueueManager.h"
#import "STConstants.h"
#import "STFacebookLoginController.h"
#import "STImageCacheController.h"
#import "STLocationManager.h"
#import "STIAPHelper.h"
#import "STChatRoomViewController.h"

#import <Tune/Tune.h>
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
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import "CoreManager.h"
#import "STTabBarViewController.h"

#import "LaunchViewController.h"
#import "STLocalNotificationService.h"
#import "STNavigationService.h"
#import "BadgeService.h"
#import "STDeepLinkService.h"

#import "STWhiteNavBarViewController.h"

#import "Branch.h"

static NSString * const kSTNewInstallKey = @"kSTNewInstallKey";

@interface AppDelegate()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    // setup Mobile App Tracker
    
    // Account Configuration info - must be set
    [Tune  initializeWithTuneAdvertiserId:kMATAdvertiserID
                        tuneConversionKey:kMATConversionKey];
    
    // Used to pass us the IFA, enables highly accurate 1-to-1 attribution.
    // Required for many advertising networks.
    [Tune setAppleAdvertisingIdentifier:[[ASIdentifierManager sharedManager] advertisingIdentifier]
                         advertisingTrackingEnabled:[[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]];
    
    NSString * newInstall = [[NSUserDefaults standardUserDefaults] objectForKey:kSTNewInstallKey];
    
    if (newInstall == nil) {
        [Tune measureEventName:@"install"];
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
    
    self.window.rootViewController = [LaunchViewController launchVC];
    self.window.backgroundColor = [AppDelegate navigationBarDefaultColor];
    [self configureAppearance];
    
    [[CoreManager notificationsService] handleNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
    
    Branch *branch = [Branch getInstance];
    [branch initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary * _Nullable params, NSError * _Nullable error) {
        if (!error && params) {
//            NSDictionary *testDict = @{@"+clicked_branch_link":@(0),
//                                       @"+is_first_session":@(0),
//                                       @"+non_branch_link":@"getstatus://getstatusapp.co/300/26913"};
//#ifdef DEBUG
//            [[CoreManager deepLinkService] addParams:testDict];
//#else
            [[CoreManager deepLinkService] addParams:params];
//#endif
            NSLog(@"params: %@", params.description);
        }
    }];
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    return YES;

}

-(void)configureAppearance{
    
    UIColor *barColor = [AppDelegate navigationBarDefaultColor];
    
    [[UITabBar appearance] setBarTintColor:barColor];
    [[UITabBar appearance] setTranslucent:NO];
    [[UITabBar appearance] setBackgroundColor:[UIColor clearColor]];
    
    [[UINavigationBar appearance] setBarTintColor:barColor];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setBackgroundColor:[UIColor clearColor]];
 
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[STWhiteNavBarViewController class]]] setBarTintColor:[UIColor whiteColor]];
    
    UIFont *font = [UIFont fontWithName:@"ProximaNova-Regular" size:20.f];
    NSDictionary *attibutes = @{NSFontAttributeName:font,
                                NSForegroundColorAttributeName:[UIColor blackColor]};
    
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[STWhiteNavBarViewController class]]] setTitleTextAttributes:attibutes];
    
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[STWhiteNavBarViewController class]]] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];

    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[STWhiteNavBarViewController class]]] setShadowImage:[[UIImage alloc] init]];

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
    [[CoreManager navigationService] resetTabBarStacks];
    [[STChatController sharedInstance] leaveCurrentRoom];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
//    [NSObject cancelPreviousPerformRequestsWithTarget:[STLocationManager sharedInstance] selector:@selector(restartLocationManager) object:nil];
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
    
    [FBSDKAppEvents activateApp];
    
    // MAT will not function without the measureSession call included
    [Tune measureSession];
    
//    [[STChatController sharedInstance] reconnect];
    [[STChatController sharedInstance] startReachabilityService];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[STChatController sharedInstance] close];
    [[STCoreDataManager sharedManager] save];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// Respond to URI scheme links
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    BOOL branchHandled = [[Branch getInstance] application:application
                                                   openURL:url
                                         sourceApplication:sourceApplication
                                                annotation:annotation];
    
    if (!branchHandled) {
        BOOL tuneHandled = [Tune handleOpenURL:url
                             sourceApplication:sourceApplication];
        if (!tuneHandled) {
            return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:sourceApplication
                                                               annotation:annotation];
        }

    }
    return NO;
}

// Respond to Universal Links
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    BOOL handledByBranch = [[Branch getInstance] continueUserActivity:userActivity];
    
    return handledByBranch;
}


- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    //the best fail of Apple ever, why calling this extra delegate method?
    if (notificationSettings.types) {
        NSLog(@"User allowed notifications");
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([CoreManager loggedIn]) {
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

    [[CoreManager badgeService] checkForNotificationNumber];
    if (application.applicationState!=UIApplicationStateActive)
        [[CoreManager notificationsService] handleNotification:userInfo];

    else
        [[CoreManager notificationsService] handleInAppNotification:userInfo];
}

#pragma mark - Helpers

+(UIColor *)navigationBarDefaultColor{
    UIColor *barColor = [UIColor colorWithRed:248.f/255.f
                                        green:248.F/255.f
                                         blue:253.f/255.f
                                        alpha:1.f];

    return barColor;
}
@end

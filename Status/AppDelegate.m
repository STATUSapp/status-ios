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
#import "STSnackBarWithActionService.h"
#import "STWhiteNavBarViewController.h"

#import "Branch.h"
#import "STSyncService.h"
#import "UIImage+Assets.h"

#import "STLoggerService.h"

static NSString * const kSTNewInstallKey = @"kSTNewInstallKey";

@interface AppDelegate()

@property (nonatomic, strong) NSDate *appOpenedDate;

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
//                                       @"+non_branch_link":@"getstatus://post/denistodirica"
////                                       @"$deeplink_path":@"getstatus://post/denistodirica/53781"
//                                       };
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
    
    self.window.backgroundColor = [AppDelegate navigationBarDefaultColor];

    [[CoreManager loggerService] startUpload];
    
    return YES;

}

-(void)configureAppearance{
    
    UIColor *barColor = [AppDelegate navigationBarDefaultColor];
    
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setTranslucent:NO];
    [[UITabBar appearance] setBackgroundColor:[UIColor clearColor]];
    
    [[UINavigationBar appearance] setBarTintColor:barColor];
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setBackgroundColor:barColor];
 
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[STWhiteNavBarViewController class]]] setBarTintColor:[UIColor whiteColor]];
    
    UIFont *font = [UIFont fontWithName:@"ProximaNova-Regular" size:20.f];
    NSDictionary *attibutes = @{NSFontAttributeName:font,
                                NSForegroundColorAttributeName:[UIColor blackColor]};
    
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[STWhiteNavBarViewController class]]] setTitleTextAttributes:attibutes];
    
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[STWhiteNavBarViewController class]]] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];

    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[STWhiteNavBarViewController class]]] setShadowImage:[[UIImage alloc] init]];
    
//    [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setDefaultTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"ProximaNova-Regular" size:16]}];
    [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setBackgroundColor:[UIColor colorWithRed:237.f/255.f green:237.f/255.f blue:239.f/255.f alpha:1.f]];
    [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setFont:[UIFont fontWithName:@"ProximaNova-Regular" size:16]];
    
    UIImage *alignedImage = [UIImage backButtonImage];
    [[UINavigationBar appearance] setBackIndicatorImage:alignedImage];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:alignedImage];
    [[UINavigationBar appearance] setBackIndicatorImage:alignedImage];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[CoreManager navigationService] resetTabBarStacks];
    [[STChatController sharedInstance] leaveCurrentRoom];
    [[CoreManager coreDataService] save];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"NetworkQueueStstus: %@",[[CoreManager networkService] debugDescription]);
    //save the resume date
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setValue:[NSDate date] forKey:@"RESUME_DATE"];
    [ud synchronize];

//    [NSObject cancelPreviousPerformRequestsWithTarget:[STLocationManager sharedInstance] selector:@selector(restartLocationManager) object:nil];
    [[STChatController sharedInstance] close];
    [[CoreManager coreDataService] save];
    //[[STLocationManager sharedInstance] startLocationUpdates];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[CoreManager syncService] syncBrands];
    if (!_appOpenedDate) {
        _appOpenedDate = [NSDate date];
    }else{
        //load the resume date
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSDate *resumeDate = [ud valueForKey:@"RESUME_DATE"];
        NSTimeInterval intervalSinceNow = [resumeDate timeIntervalSinceNow] * (-1.f);
        NSTimeInterval fiveMinutesInterval = 60 * 5;
        //update home content if more then 5 minutes left
        if (intervalSinceNow > fiveMinutesInterval &&
            ([[CoreManager networkService] getAccessToken] !=nil)) {
            [[CoreManager localNotificationService] postNotificationName:STHomeFlowShouldBeReloadedNotification object:nil userInfo:nil];
        }
    }
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
    [[CoreManager coreDataService] save];
    [[CoreManager loggerService] saveLogsToDisk];
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// Respond to URI scheme links

-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    
    BOOL branchHandled = [[Branch getInstance] application:app
                                                   openURL:url
                                                   options:options];
    
    if (!branchHandled) {
        BOOL tuneHandled = [Tune handleOpenURL:url options:options];
        if (!tuneHandled) {
            return [[FBSDKApplicationDelegate sharedInstance] application:app
                                                                  openURL:url
                                                                  options:options];
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
    if ([CoreManager loggedIn] &&
        ![CoreManager isGuestUser]) {
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

#pragma mark - UITabBarControllerDelegate
-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    STTabBarIndex index = [tabBarController.viewControllers indexOfObject:viewController];
    if (index != STTabBarIndexExplore && [CoreManager isGuestUser]) {
        [[CoreManager snackWithActionService] showSnackBarWithType:STSnackWithActionBarTypeGuestMode];
        return NO;
    }
    return YES;
}

@end

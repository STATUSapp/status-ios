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
#import "STWebServiceController.h"
#import "STConstants.h"
#import "STFacebookController.h"
#import "STImageCacheController.h"
#import "STLocationManager.h"
#import "STIAPHelper.h"
#import "STChatRoomViewController.h"

#import <MobileAppTracker/MobileAppTracker.h>
#import <AdSupport/AdSupport.h>

#import "STInviteController.h"
#import "STChatController.h"
#import "STFacebookAlbumsViewController.h"

#import "STCoreDataManager.h"

static NSString * const kSTNewInstallKey = @"kSTNewInstallKey";

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
    [[STImageCacheController sharedInstance] cleanTemporaryFolder];
    [application setStatusBarHidden:YES];
    self.badgeNumber = application.applicationIconBadgeNumber;
    //[[NSNotificationCenter defaultCenter] postNotificationName: STNotificationBadgeValueDidChanged object:nil];
    [self handleNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
    
    
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
    
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    [STWebServiceController sharedInstance].isPerformLoginOrRegistration=FALSE;
    
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    NSMutableArray *stackVCs = [NSMutableArray arrayWithArray:navController.viewControllers];
    BOOL removed = NO;
    while (![[stackVCs lastObject] isKindOfClass:[STFlowTemplateViewController class]]) {
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
    [[STFacebookController sharedInstance] loadTokenFromKeyChain];
    
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

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //NSLog(@"APN Token --- %@", token);
    if ([STWebServiceController sharedInstance].accessToken!=nil) {
        [[STWebServiceController sharedInstance] setAPNToken:token withCompletion:^(NSDictionary *response) {
            if ([response[@"status_code"] integerValue]==STWebservicesSuccesCod)  NSLog(@"APN Token set.");
            else  NSLog(@"APN token NOT set.");
        } orError:nil];
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSLog(@"Notif: %@", userInfo);
    self.badgeNumber = [userInfo[@"aps"][@"badge"] integerValue];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName: STNotificationBadgeValueDidChanged object:nil];
   
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        [self handleNotification:userInfo];
    }
    
}

#pragma mark - Helper

-(void) handleNotification:(NSDictionary *) notif{
    
    if (notif!=nil) {
        UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
        STFlowTemplateViewController *viewController = (STFlowTemplateViewController *)[navController.viewControllers firstObject];
        [viewController handleNotification:notif];
    }
}

-(void)checkForNotificationNumber{
    __weak AppDelegate *weakSelf = self;
    if ([STWebServiceController sharedInstance].accessToken != nil &&
        [STWebServiceController sharedInstance].accessToken.length > 0) {
        [[STWebServiceController sharedInstance] getUnreadNotificationsCountWithCompletion:^(NSDictionary *response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.badgeNumber = [response[@"count"] integerValue];
            });
        } andErrorCompletion:nil];
    }
}

@end

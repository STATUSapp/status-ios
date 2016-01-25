//
//  STFacebookShareController.m
//  Status
//
//  Created by Cosmin Andrus on 2/27/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STFacebookLoginController.h"
#import "STConstants.h"
#import "STFlowTemplateViewController.h"
#import "KeychainItemWrapper.h"
#import "STImageCacheController.h"
#import "AppDelegate.h"
#import "STLocationManager.h"
#import "STChatController.h"
#import "STSetAPNTokenRequest.h"

#import <MobileAppTracker/MobileAppTracker.h>
#import <AdSupport/AdSupport.h>
#import "STCoreDataManager.h"
#import <Crashlytics/Crashlytics.h>

#import "STLoginRequest.h"
#import "STRegisterRequest.h"
#import "STGetUserSettingsRequest.h"
#import "STFacebookHelper.h"
#import "NSDate+Additions.h"

#import <FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@implementation STFacebookLoginController
+(STFacebookLoginController *) sharedInstance{
    static STFacebookLoginController *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

-(id)init{
    self = [super init];
    if (self) {
        
        _loginButton = [FBSDKLoginButton new];
        _loginButton.defaultAudience = FBSDKDefaultAudienceEveryone;
        _loginButton.readPermissions = @[@"public_profile", @"email",@"user_birthday",@"user_about_me", @"user_location",@"user_photos"];
        _loginButton.publishPermissions = @[@"publish_actions"];
        
        [_loginButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        _loginButton.delegate = self;
        if ([FBSDKAccessToken currentAccessToken]) {
            [self loginOrRegister];
        }
         
    }
    return self;
}

#pragma mark - Facebook DelegatesFyou

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    
    if (self.logoutDelegate&&[self.logoutDelegate respondsToSelector:@selector(facebookControllerDidLoggedOut)]) {
        [self.logoutDelegate performSelector:@selector(facebookControllerDidLoggedOut)];
    }
    [STFacebookLoginController sharedInstance].fetchedUserData = nil;
    [[NSUserDefaults standardUserDefaults] synchronize];
    [FBSDKAccessToken setCurrentAccessToken:nil];
    [FBSDKProfile setCurrentProfile:nil];
    //            [weakSelf presentLoginScene];
    [NSObject cancelPreviousPerformRequestsWithTarget:[STLocationManager sharedInstance] selector:@selector(restartLocationManager) object:nil];
    [[STLocationManager sharedInstance] stopLocationUpdates];
    [[STLocationManager sharedInstance] setLatestLocation:nil];
    [[STImageCacheController sharedInstance] cleanTemporaryFolder];
    [[STCoreDataManager sharedManager] cleanLocalDataBase];
    STRequestCompletionBlock completion = ^(id response, NSError *error){
        if ([response[@"status_code"] integerValue]==200){
            NSLog(@"APN Token deleted.");
            [[STFacebookLoginController sharedInstance] deleteAccessToken];
        }
        else  NSLog(@"APN token NOT deleted.");
    };
    [STSetAPNTokenRequest setAPNToken:@"" withCompletion:completion failure:nil];
    
    [[STChatController sharedInstance] close];

    //[self deleteAccessToken];
}

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
    if (error!=nil) {
        [STFacebookLoginController sharedInstance].currentUserId = nil;
    }
    else
        [self loginOrRegister];
}

-(void)loadTokenFromKeyChain {
    KeychainItemWrapper *keychainWrapperAccessToken = [[KeychainItemWrapper alloc] initWithIdentifier:@"STUserAuthToken" accessGroup:nil];
    [STNetworkQueueManager sharedManager].accessToken = [keychainWrapperAccessToken objectForKey:(__bridge id)(kSecValueData)];
    NSLog(@"Loaded Access Token: %@",[STNetworkQueueManager sharedManager].accessToken);
}

-(void)deleteAccessToken {
    KeychainItemWrapper *keychainWrapperAccessToken = [[KeychainItemWrapper alloc] initWithIdentifier:@"STUserAuthToken" accessGroup:nil];
    [keychainWrapperAccessToken resetKeychainItem];
    [[STNetworkManager sharedManager] clearQueue];
    [STNetworkQueueManager sharedManager].accessToken = nil;
}

-(void) saveAccessToken:(NSString *) accessToken{
    KeychainItemWrapper *keychainWrapperAccessToken = [[KeychainItemWrapper alloc] initWithIdentifier:@"STUserAuthToken" accessGroup:nil];
    [keychainWrapperAccessToken setObject:accessToken forKey:(__bridge id)(kSecValueData)];
}

- (void)setUpCrashlyticsForUserId:(NSString *)userId andEmail:(NSString *)email andUserName:(NSString *)userName{
    [[Crashlytics sharedInstance] setUserIdentifier:userId];
    [[Crashlytics sharedInstance] setUserEmail:email];
    [[Crashlytics sharedInstance] setUserName:userName];
}

- (void)setUpEnvironment:(NSDictionary *)response andUserInfo:(NSDictionary *)userInfo{
    [STNetworkQueueManager sharedManager].accessToken = response[@"token"];
    [STImageCacheController sharedInstance].photoDownloadBaseUrl = response[@"baseUrlStorage"];
    [STChatController sharedInstance].chatSocketUrl = response[@"hostnameChat"];
    [STChatController sharedInstance].chatPort = [response[@"portChat"] integerValue];
    [[STLocationManager sharedInstance] startLocationUpdates];
    [self saveAccessToken:response[@"token"]];
    self.currentUserId = response[@"user_id"];
    [[STChatController sharedInstance] forceReconnect];
    [self setUpCrashlyticsForUserId:response[@"user_id"] andEmail:userInfo[@"email"] andUserName:userInfo[@"full_name"]];
    [self requestRemoteNotificationAccess];
    [self announceDelegate];
    //get settings from server
    [self getUserSettingsFromServer];
}

-(void) loginOrRegister{
    if ([STNetworkQueueManager sharedManager].isPerformLoginOrRegistration==FALSE) {
        [STNetworkQueueManager sharedManager].isPerformLoginOrRegistration = TRUE;
    }
    else
        return;
    
    if([[FBSDKAccessToken currentAccessToken] tokenString]==nil){
        [STNetworkQueueManager sharedManager].isPerformLoginOrRegistration = FALSE;
        return;
    }
    [FBSDKAccessToken refreshCurrentAccessToken:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        
        __weak STFacebookLoginController *weakSelf = self;
        __block NSMutableDictionary *userInfo = [NSMutableDictionary new];

        STRequestCompletionBlock registerCompletion = ^(id response, NSError *error){
            [STNetworkQueueManager sharedManager].isPerformLoginOrRegistration=FALSE;
            if ([response[@"status_code"] integerValue] ==STWebservicesSuccesCod) {
                [weakSelf measureRegister];
                [weakSelf setUpEnvironment:response andUserInfo:userInfo];
                if (_delegate && [_delegate respondsToSelector:@selector(facebookControllerDidRegister)]) {
                    [_delegate facebookControllerDidRegister];
                }
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong with the registration." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        };
        
        STRequestFailureBlock failBlock = ^(NSError *error){
            [STNetworkQueueManager sharedManager].isPerformLoginOrRegistration=FALSE;
        };
        
        STRequestCompletionBlock loginCompletion = ^(id response, NSError *error){
            [STNetworkQueueManager sharedManager].isPerformLoginOrRegistration=FALSE;
            if ([response[@"status_code"] integerValue]==STWebservicesNeedRegistrationCod) {
               
                [STRegisterRequest registerWithUserInfo:userInfo
                                         withCompletion:registerCompletion
                                                failure:failBlock];
            }
            else if ([response[@"status_code"] integerValue]==STWebservicesSuccesCod){
                [weakSelf setTrackerAsExistingUser];
                [weakSelf setUpEnvironment:response andUserInfo:userInfo];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong on login." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        };
        NSString *userFbId = [[FBSDKAccessToken currentAccessToken] userID];
        
        userInfo[@"fb_token"] = [[FBSDKAccessToken currentAccessToken] tokenString];
        userInfo[@"facebook_id"] = userFbId;

        [[STFacebookHelper new] getUserExtendedInfoWithCompletion:^(NSDictionary *info) {
            if (info[@"birthday"]) {
                userInfo[@"birthday"] = [NSDate birthdayStringFromFacebookBirthday:info[@"birthday"]];
            }
            if (info[@"email"]) {
                userInfo[@"email"] = info[@"email"];
            }
            if (info[@"picture"][@"data"][@"url"]) {
                userInfo[@"facebook_image_link"] = info[@"picture"][@"data"][@"url"];
            }
            if (info[@"name"]!=nil){
                userInfo[@"full_name"] = info[@"name"];
            }
            if (info[@"gender"]!=nil) {
                userInfo[@"gender"] = info[@"gender"];
            }
            if (info[@"bio"]!=nil) {
                userInfo[@"bio"] = info[@"bio"];
            }
            if (info[@"location"][@"name"]!=nil) {
                userInfo[@"location"] = info[@"location"][@"name"];
            }
            _fetchedUserData = [NSDictionary dictionaryWithDictionary:userInfo];
            [STLoginRequest loginWithUserInfo:userInfo
                               withCompletion:loginCompletion
                                      failure:failBlock];
            
        }];
    }];

    
}

-(void) announceDelegate{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(facebookControllerDidLoggedIn)]) {
        [self.delegate performSelector:@selector(facebookControllerDidLoggedIn)];
    }
}

- (void)setTrackerAsExistingUser {
    [Tune setExistingUser:YES];
    [Tune measureEventName:@"login"];
}

- (void)measureRegister {
    [Tune measureEventName:@"registration"];
}

static const UIRemoteNotificationType REMOTE_NOTIFICATION_TYPES_REQUIRED = (UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound);

- (void)requestRemoteNotificationAccess;
{
    bool isIOS8OrGreater = [[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)];
    if (!isIOS8OrGreater)
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:REMOTE_NOTIFICATION_TYPES_REQUIRED];
        return;
    }

    UIUserNotificationSettings *settings =
    [UIUserNotificationSettings
     settingsForTypes: (UIUserNotificationTypeBadge |
                        UIUserNotificationTypeSound |
                        UIUserNotificationTypeAlert)
     categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    
}

- (void)getUserSettingsFromServer {
    STRequestCompletionBlock completion = ^(id response, NSError *error){
        if ([response[@"status_code"] integerValue] ==STWebservicesSuccesCod) {
            NSDictionary * settingsDict = response[@"data"];
            [[NSUserDefaults standardUserDefaults] setObject:settingsDict forKey:STSettingsDictKey];
        }
    };
    
    [STGetUserSettingsRequest getUserSettingsWithCompletion:completion failure:nil];

}

@end

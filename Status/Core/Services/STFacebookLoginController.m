//
//  STFacebookShareController.m
//  Status
//
//  Created by Cosmin Andrus on 2/27/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STFacebookLoginController.h"
#import "STConstants.h"
#import "KeychainItemWrapper.h"
#import "STImageCacheController.h"
#import "AppDelegate.h"
#import "STLocationManager.h"
#import "STChatController.h"
#import "STSetAPNTokenRequest.h"

#import <Tune/Tune.h>
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

#import "CreateDataModelHelper.h"
#import "STLocalNotificationService.h"

#import "STUserProfile.h"
#import "CoreManager.h"
#import "STUserProfilePool.h"
#import "STNavigationService.h"

@interface STFacebookLoginController ()<FBSDKLoginButtonDelegate>

@property (nonatomic, strong) NSString *currentUserId;
@property (nonatomic, strong) NSDictionary *fetchedUserData;
@property (nonatomic, strong) STUserProfile *loggedInUserProfile;

@end

@implementation STFacebookLoginController

-(id)init{
    self = [super init];
    if (self) {
    }
    return self;
}

- (FBSDKLoginButton *)facebookLoginButton{
    FBSDKLoginButton *_loginButton = [FBSDKLoginButton new];
    _loginButton.defaultAudience = FBSDKDefaultAudienceEveryone;
    _loginButton.readPermissions = @[@"public_profile", @"email",@"user_birthday",@"user_about_me", @"user_location",@"user_photos"];
    _loginButton.publishPermissions = @[@"publish_actions"];
    
    _loginButton.delegate = self;
    
    return _loginButton;

}

- (NSString *)currentUserUuid{
    return _currentUserId;
}
- (NSString *)currentUserFullName{
    NSString *fullName = _fetchedUserData[@"full_name"];
    
    if (fullName == nil) {
        _loggedInUserProfile = [[CoreManager profilePool] getUserProfileWithId:[self currentUserId]];
        if (_loggedInUserProfile) {
            return [_loggedInUserProfile fullName];
        }
    }
    return fullName;
}

- (void)startLoginIfPossible {
    if ([FBSDKAccessToken currentAccessToken]) {
        [self loginOrRegister];
    }
    else
        [self logout];
}

#pragma mark - Facebook DelegatesFyou

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    [[CoreManager localNotificationService] postNotificationName:kNotificationFacebokDidLogout object:nil userInfo:nil];
    [self logout];
}

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
    if (error!=nil) {
        _currentUserId = nil;
    }
    else
    {
        [[CoreManager localNotificationService] postNotificationName:kNotificationFacebokDidLogin object:nil userInfo:nil];
        [self loginOrRegister];
        
    }
}

- (void)setUpCrashlyticsForUserId:(NSString *)userId andEmail:(NSString *)email andUserName:(NSString *)userName{
    [[Crashlytics sharedInstance] setUserIdentifier:userId];
    [[Crashlytics sharedInstance] setUserEmail:email];
    [[Crashlytics sharedInstance] setUserName:userName];
}

- (void)setUpEnvironment:(NSDictionary *)response andUserInfo:(NSDictionary *)userInfo{
    [CoreManager networkService].accessToken = response[@"token"];
    [CoreManager imageCacheService].photoDownloadBaseUrl = response[@"baseUrlStorage"];
    [STChatController sharedInstance].chatSocketUrl = response[@"hostnameChat"];
    [STChatController sharedInstance].chatPort = [response[@"portChat"] integerValue];
    [[CoreManager locationService] startLocationUpdates];
    NSString *userId = [CreateDataModelHelper validStringIdentifierFromValue:response[@"user_id"]];
    self.currentUserId = userId;
//    [[STChatController sharedInstance] forceReconnect];
    [self setUpCrashlyticsForUserId:userId andEmail:userInfo[@"email"] andUserName:userInfo[@"full_name"]];
    [self requestRemoteNotificationAccess];
    [[CoreManager localNotificationService] postNotificationName:kNotificationUserDidLoggedIn object:nil userInfo:nil];
    //get settings from server
    [self getUserSettingsFromServer];
}

-(void)logout{
    [[CoreManager localNotificationService] postNotificationName:kNotificationUserDidLoggedOut object:nil userInfo:nil];
    _fetchedUserData = nil;
    [[NSUserDefaults standardUserDefaults] synchronize];
    [FBSDKAccessToken setCurrentAccessToken:nil];
    [FBSDKProfile setCurrentProfile:nil];
    //            [weakSelf presentLoginScene];
    [NSObject cancelPreviousPerformRequestsWithTarget:[CoreManager locationService] selector:@selector(restartLocationManager) object:nil];
    [[CoreManager locationService] stopLocationUpdates];
    [[CoreManager locationService] setLatestLocation:nil];
    [[CoreManager imageCacheService] cleanTemporaryFolder];
    [[STCoreDataManager sharedManager] cleanLocalDataBase];
    STRequestCompletionBlock completion = ^(id response, NSError *error){
        if ([response[@"status_code"] integerValue]==200){
            NSLog(@"APN Token deleted.");
            [[CoreManager networkService] deleteAccessToken];
        }
        else  NSLog(@"APN token NOT deleted.");
    };
    [STSetAPNTokenRequest setAPNToken:@"" withCompletion:completion failure:nil];
    
    [[STChatController sharedInstance] close];

}

-(void) loginOrRegister{
    if ([[CoreManager networkService] canSendLoginOrRegisterRequest]==FALSE)
        return;
    
    if([[FBSDKAccessToken currentAccessToken] tokenString]==nil){
        return;
    }
    [FBSDKAccessToken refreshCurrentAccessToken:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        
        __weak STFacebookLoginController *weakSelf = self;
        __block NSMutableDictionary *userInfo = [NSMutableDictionary new];

        STRequestCompletionBlock registerCompletion = ^(id response, NSError *error){
            if ([response[@"status_code"] integerValue] ==STWebservicesSuccesCod) {
                [weakSelf measureRegister];
                [weakSelf setUpEnvironment:response andUserInfo:userInfo];
                [[CoreManager localNotificationService] postNotificationName:kNotificationUserDidRegister object:nil userInfo:nil];
            }
            else
            {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Something went wrong with the registration." preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [[CoreManager navigationService] presentAlertController:alert];
            }
        };
        
        STRequestFailureBlock failBlock = ^(NSError *error){
            NSLog(@"Error: %@", error.debugDescription);
        };
        
        STRequestCompletionBlock loginCompletion = ^(id response, NSError *error){
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
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Something went wrong on login." preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [[CoreManager navigationService] presentAlertController:alert];
            }
        };
        NSString *userFbId = [[FBSDKAccessToken currentAccessToken] userID];
        
        userInfo[@"fb_token"] = [[FBSDKAccessToken currentAccessToken] tokenString];
        userInfo[@"facebook_id"] = userFbId;

        [[CoreManager facebookService] getUserExtendedInfoWithCompletion:^(NSDictionary *info) {
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
            if (info[@"about"]!=nil) {
                userInfo[@"bio"] = info[@"about"];
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

- (void)setTrackerAsExistingUser {
    [Tune setExistingUser:YES];
    [Tune measureEventName:@"login"];
}

- (void)measureRegister {
    [Tune measureEventName:@"registration"];
}

- (void)requestRemoteNotificationAccess;
{
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

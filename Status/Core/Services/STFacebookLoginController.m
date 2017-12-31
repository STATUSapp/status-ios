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
#import "STDataAccessUtils.h"

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
        STUserProfile *up = [self userProfile];
        if (up) {
            return [up fullName];
        }
    }
    return fullName;
}

- (STProfileGender)currentUserGender{
    return [[self userProfile] profileGender];
}

- (void)startLoginIfPossible {
    if ([FBSDKAccessToken currentAccessToken]) {
        [self loginOrRegister];
    }
    else{
        [self logout];
        [self loginAsGuest];
    }
}

- (STUserProfile *)userProfile{
    if (_loggedInUserProfile) {
        return _loggedInUserProfile;
    }
    if (_currentUserId) {
        _loggedInUserProfile = [[CoreManager profilePool] getUserProfileWithId:_currentUserId];
        
    }
    return _loggedInUserProfile;
}

#pragma mark - Guest User
- (NSDictionary *)newGuestPayload{
    NSDate *nowDate = [NSDate date];
    NSString *facebookId = [NSString stringWithFormat:@"%0.f", nowDate.timeIntervalSince1970];
    NSString *email = [NSString stringWithFormat:@"ios_guest_%@@@guest.com", facebookId];
    NSMutableDictionary *result = [@{} mutableCopy];
    result[@"email"] = email;
    result[@"facebook_image_link"] = @"";
    result[@"fb_token"] = @"";
    result[@"phone_number"] = @"";
    result[@"full_name"] = @"Guest";
    result[@"birthday"] = @"";
    result[@"facebook_id"] = facebookId;
    result[@"gender"] = @"other";
    result[@"bio"] = @"";
    result[@"location"] = @"";
    return result;
}

-(BOOL)isGuestUser{
    if (_fetchedUserData) {
        NSString *email = _fetchedUserData[@"email"];
        return [email containsString:@"ios_guest"];
    }
    return YES;
}

-(NSDictionary *)loadGuestUser{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *guestUser = [ud valueForKey:@"GUEST_USER_PAYLOAD"];
    if (guestUser.allKeys.count == 0) {
        guestUser = [self newGuestPayload];
        [ud setValue:guestUser forKey:@"GUEST_USER_PAYLOAD"];
        [ud synchronize];
    }
    return guestUser;
}

-(void)loginAsGuest{
    if (![self canLoginOrRegister]) {
        return;
    }
    NSDictionary *userInfo = [self loadGuestUser];
    [self sendLoginOrregisterRequest:userInfo];
}

#pragma mark - Facebook DelegatesFyou

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    [[CoreManager localNotificationService] postNotificationName:kNotificationFacebokDidLogout object:nil userInfo:nil];
    [self logout];
}

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
    if (error!=nil) {
        //TODO: add log here
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
    STUserProfile *userProfile = [self userProfile];
    if (userProfile &&
        ![userProfile.uuid isEqualToString:userId]) {
        //invalidate the user profile
        [[CoreManager profilePool] removeProfiles:@[userProfile]];
        _loggedInUserProfile = nil;
    }
    if (userProfile == nil) {
        [STDataAccessUtils getUserProfileForUserId:_currentUserId
                                     andCompletion:^(NSArray *objects, NSError *error) {
                                         _loggedInUserProfile = [objects firstObject];
                                         if (_loggedInUserProfile) {
                                             [[CoreManager profilePool] addProfiles:@[_loggedInUserProfile]];
                                         }
                                         [[CoreManager localNotificationService] postNotificationName:kNotificationUserDidLoggedIn object:nil userInfo:nil];
                                     }];
    }else{
        [[CoreManager localNotificationService] postNotificationName:kNotificationUserDidLoggedIn object:nil userInfo:nil];
    }
    
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
    [[CoreManager coreDataService] cleanLocalDataBase];
    STRequestCompletionBlock completion = ^(id response, NSError *error){
        if ([response[@"status_code"] integerValue]==200){
            NSLog(@"APN Token deleted.");
//            [[CoreManager networkService] deleteAccessToken];
        }
        else  NSLog(@"APN token NOT deleted.");
    };
    [STSetAPNTokenRequest setAPNToken:@"" withCompletion:completion failure:nil];
    
    [[STChatController sharedInstance] close];

}

-(BOOL)canLoginOrRegister{
    if ([[CoreManager networkService] canSendLoginOrRegisterRequest]==FALSE){
        //TODO: add log here
        return NO;
    }
    
    return YES;
}

-(void) loginOrRegister{
    if (![self canLoginOrRegister]) {
        return;
    }
    if([[FBSDKAccessToken currentAccessToken] tokenString]==nil){
        //TODO: add log here
        return ;
    }
    [FBSDKAccessToken refreshCurrentAccessToken:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        
        if (error!=nil) {
            //TODO: add log here
            return ;
        }
        __block NSMutableDictionary *userInfo = [NSMutableDictionary new];
        
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
            [self sendLoginOrregisterRequest:userInfo];
        }];
    }];
}

-(void)sendLoginOrregisterRequest:(NSDictionary *)userInfo{
    __weak STFacebookLoginController *weakSelf = self;
    _fetchedUserData = [NSDictionary dictionaryWithDictionary:userInfo];
    STRequestCompletionBlock registerCompletion = ^(id response, NSError *error){
        if ([response[@"status_code"] integerValue] ==STWebservicesSuccesCod) {
            [weakSelf measureRegister];
            [weakSelf setUpEnvironment:response andUserInfo:userInfo];
            [[CoreManager localNotificationService] postNotificationName:kNotificationUserDidRegister object:nil userInfo:nil];
        }
        else
        {
            //TODO: add log here
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Something went wrong with the registration." preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [[CoreManager navigationService] presentAlertController:alert];
        }
    };
    
    STRequestFailureBlock failBlock = ^(NSError *error){
        //TODO: add log here
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
            //TODO: add log here
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Something went wrong on login." preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [[CoreManager navigationService] presentAlertController:alert];
        }
    };

    [STLoginRequest loginWithUserInfo:userInfo
                       withCompletion:loginCompletion
                              failure:failBlock];
}

- (void)setTrackerAsExistingUser {
    [Tune setExistingUser:YES];
    [Tune measureEventName:@"login"];
}

- (void)measureRegister {
    [Tune measureEventName:@"registration"];
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

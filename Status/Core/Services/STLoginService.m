//
//  STFacebookShareController.m
//  Status
//
//  Created by Cosmin Andrus on 2/27/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STLoginService.h"
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

#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import "CreateDataModelHelper.h"
#import "STLocalNotificationService.h"

#import "STUserProfile.h"
#import "CoreManager.h"
#import "STUserProfilePool.h"
#import "STNavigationService.h"
#import "STDataAccessUtils.h"
#import "STInstagramLoginService.h"
#import "FBSDKLoginManager.h"
#import <WebKit/WebKit.h>

@interface STLoginService ()

@property (nonatomic, strong) NSString *currentUserId;
@property (nonatomic, strong) NSDictionary *fetchedUserData;
@property (nonatomic, strong) STUserProfile *loggedInUserProfile;

@property (nonatomic, assign) BOOL manualLogout;
@property (nonatomic, strong, readwrite) STLoginView *loginView;

@property (nonatomic, assign) STLoginRequestType lastLoginType;
@end

@implementation STLoginService

-(id)init{
    self = [super init];
    if (self) {
        _manualLogout = NO;
        _loginView = [STLoginView loginViewWithDelegate:self];
        _lastLoginType = [self loadLastLoginType];
    }
    return self;
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
    
    if (_lastLoginType == STLoginRequestTypeFacebook &&
        [FBSDKAccessToken currentAccessToken]) {
        [self initiateFacebookLogin];
    }else if (_lastLoginType == STLoginRequestTypeInstagram &&
              [CoreManager instagramLoginService].clientInstagramToken){
        [self initiateInstagramLogin];
    }else{
        self.manualLogout = NO;
        [self logout];
        [self loginAsGuest];
    }
}

- (void)logoutManually {
    [[CoreManager localNotificationService] postNotificationName:kNotificationFacebokDidLogout object:nil userInfo:nil];
    self.manualLogout = YES;
    [self logout];
    [self loginAsGuest];
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
    if (self.lastLoginType == STLoginRequestTypeInstagram) {
        return NO;
    }else{
        if (_fetchedUserData) {
            NSString *email = _fetchedUserData[@"email"];
            if (email) {
                return [email containsString:@"ios_guest"];
            }
        }
        return YES;
    }
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
    [self sendLoginOrregisterRequest:userInfo loginType:STLoginRequestTypeFacebook];
}

#pragma mark - Last Login Type
- (void)saveLastLoginType:(STLoginRequestType)loginType{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setValue:@(loginType) forKey:@"LAST_LOGIN_SUCCESS"];
    [ud synchronize];
}

- (STLoginRequestType)loadLastLoginType{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSNumber *result = [ud valueForKey:@"LAST_LOGIN_SUCCESS"];
    STLoginRequestType lastloginType;
    if (!result) {
        //assume Facebook Login since before 2.8 version was not any other other option
        lastloginType = STLoginRequestTypeFacebook;
    }else{
        lastloginType = [result integerValue];
    }
    
    return lastloginType;
}

- (void)clearLoginType{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setValue:nil forKey:@"LAST_LOGIN_SUCCESS"];

}

#pragma mark - General Helpers

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
    STUserProfile *userProfile = [self userProfile];
    if (userProfile ||
        ![userProfile.uuid isEqualToString:userId]) {
        //invalidate the user profile
        if (userProfile) {
            [[CoreManager profilePool] removeProfiles:@[userProfile]];
        }
        _loggedInUserProfile = nil;
    }
    self.currentUserId = userId;
//    [[STChatController sharedInstance] forceReconnect];
    [self setUpCrashlyticsForUserId:userId andEmail:userInfo[@"email"] andUserName:userInfo[@"full_name"]];
    if (_loggedInUserProfile == nil) {
        __weak STLoginService *weakSelf=self;
        [STDataAccessUtils getUserProfileForUserId:_currentUserId
                                     andCompletion:^(NSArray *objects, NSError *error) {
                                         __strong STLoginService *strongSelf = weakSelf;
                                         strongSelf.loggedInUserProfile = [objects firstObject];
                                         if (strongSelf.loggedInUserProfile) {
                                             [[CoreManager profilePool] addProfiles:@[strongSelf.loggedInUserProfile]];
                                         }
                                         [[CoreManager localNotificationService] postNotificationName:kNotificationUserDidLoggedIn object:nil userInfo:@{kManualLogoutKey:@(strongSelf.manualLogout)}];
                                         strongSelf.manualLogout = NO;
                                     }];
    }else{
        [[CoreManager localNotificationService] postNotificationName:kNotificationUserDidLoggedIn object:nil userInfo:@{kManualLogoutKey:@(self.manualLogout)}];
        self.manualLogout = NO;
    }
    
    //get settings from server
    [self getUserSettingsFromServer];
}

-(void)logout{
    [[CoreManager localNotificationService] postNotificationName:kNotificationUserDidLoggedOut object:nil userInfo:nil];
    _fetchedUserData = nil;
    [FBSDKProfile setCurrentProfile:nil];

    [self clearLoginType];
    self.lastLoginType = STLoginRequestTypeFacebook;
    
    //invalidate the cache
    [[CoreManager imageCacheService] cleanTemporaryFolder];

    //invalidate the cookies
    WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
    [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
                     completionHandler:^(NSArray<WKWebsiteDataRecord *> * __nonnull records) {
                         for (WKWebsiteDataRecord *record  in records)
                         {
                             NSLog(@"Cookie record = %@", record.displayName);
                             if ( [record.displayName containsString:@"facebook"]||
                                 [record.displayName containsString:@"instagram"] ||
                                 [record.displayName containsString:kReachableURL])
                             {
                                 [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes
                                                                           forDataRecords:@[record]
                                                                        completionHandler:^{
                                                                            NSLog(@"Cookies for %@ deleted successfully",record.displayName);
                                                                        }];
                             }
                         }
                     }];
    //clear instagram data
    [[CoreManager instagramLoginService] clearService];
    
    //clear facebook data
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logOut];
    [FBSDKAccessToken setCurrentAccessToken:nil];

    //delete APNS token
    STRequestCompletionBlock completion = ^(id response, NSError *error){
        if ([response[@"status_code"] integerValue]==200){
            NSLog(@"APN Token deleted.");
//            [[CoreManager networkService] deleteAccessToken];
        }
        else  NSLog(@"APN token NOT deleted.");
    };
    [STSetAPNTokenRequest setAPNToken:@"" withCompletion:completion failure:nil];

    //close chat socket
    [[STChatController sharedInstance] close];
}

-(BOOL)canLoginOrRegister{
    if ([[CoreManager networkService] canSendLoginOrRegisterRequest]==FALSE){
        //TODO: add log here
        return NO;
    }
    
    return YES;
}

- (void)buildLoginRegisterParams {
    __block NSMutableDictionary *userInfo = [NSMutableDictionary new];
    __weak STLoginService *weakSelf = self;
    [[CoreManager facebookService] getUserExtendedInfoWithCompletion:^(NSDictionary *info) {
        if (info == nil) {
            //an error or cancel happened
            //show and alert
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Something went wrong with Facebook login. Please try again later." preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [[CoreManager navigationService] presentAlertController:alert];            
        }else{
            __strong STLoginService *strongSelf = weakSelf;
            NSString *userFbId = [[FBSDKAccessToken currentAccessToken] userID];
            userInfo[@"fb_token"] = [[FBSDKAccessToken currentAccessToken] tokenString];
            userInfo[@"facebook_id"] = userFbId;
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
            [strongSelf sendLoginOrregisterRequest:userInfo loginType:STLoginRequestTypeFacebook];
        }
    }];
}

- (void)showSomethingWrongAlertOnLogin {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Something went wrong on login." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [[CoreManager navigationService] presentAlertController:alert];
}

-(void)sendLoginOrregisterRequest:(NSDictionary *)userInfo
                        loginType:(STLoginRequestType)loginType{
    __weak STLoginService *weakSelf = self;
    _fetchedUserData = [NSDictionary dictionaryWithDictionary:userInfo];
    STRequestCompletionBlock registerCompletion = ^(id response, NSError *error){
        __strong STLoginService *strongSelf = weakSelf;
        if ([response[@"status_code"] integerValue] ==STWebservicesSuccesCod) {
            [strongSelf measureRegister];
            strongSelf.lastLoginType = loginType;
            [strongSelf setUpEnvironment:response andUserInfo:userInfo];
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
        __strong STLoginService *strongSelf = weakSelf;
        NSLog(@"Error: %@", error.debugDescription);
        [strongSelf showSomethingWrongAlertOnLogin];
    };

    STRequestCompletionBlock loginCompletion = ^(id response, NSError *error){
        __strong STLoginService *strongSelf = weakSelf;
        if ([response[@"status_code"] integerValue]==STWebservicesNeedRegistrationCod) {
            
            [STRegisterRequest registerWithUserInfo:userInfo
                                     withCompletion:registerCompletion
                                            failure:failBlock];
        }
        else if ([response[@"status_code"] integerValue]==STWebservicesSuccesCod){
            [strongSelf setTrackerAsExistingUser];
            strongSelf.lastLoginType = loginType;
            [strongSelf saveLastLoginType:loginType];
            if (loginType == STLoginRequestTypeInstagram) {
                [[CoreManager instagramLoginService] commitInstagramClientToken];
            }
            [strongSelf setUpEnvironment:response andUserInfo:userInfo];
        }
        else
        {
            //TODO: add log here
            [strongSelf showSomethingWrongAlertOnLogin];
        }
    };

    [STLoginRequest loginWithUserInfo:userInfo
                            loginType:loginType
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

#pragma mark - STLoginViewDelegate <NSObject>

- (void)loginViewDidSelectFacebook{
    NSLog(@"facebook button pressed");
    [self initiateFacebookLogin];
}
- (void)loginViewDidSelectInstagram{
    NSLog(@"instagram button pressed");
    [self initiateInstagramLogin];
}

#pragma mark - Facebook Login Helpers

- (void)initiateFacebookLogin{
    if (![self canLoginOrRegister]) {
        return;
    }
    [self buildLoginRegisterParams];
}

#pragma mark - Instagram Login Helpers
- (void)initiateInstagramLogin{
    if (![self canLoginOrRegister]) {
        return;
    }
    __weak STLoginService *weakSelf = self;
    [[CoreManager instagramLoginService] startLoginWithCompletion:^(NSError *error) {
        __strong STLoginService *strongSelf = weakSelf;
        if (!error) {
            NSString *instaClientToken = [CoreManager instagramLoginService].clientInstagramToken;
            if (!instaClientToken) {
                //show alert
                [strongSelf showSomethingWrongAlertOnLogin];
            }else{
                [strongSelf loginWithInstagramInfo];
            }
        }else{
            //show alert
            NSLog(@"Error: %@", error);
            [strongSelf showSomethingWrongAlertOnLogin];
        }
    }];
}

- (void)loginWithInstagramInfo {
    NSDictionary *userInfo = @{@"instagram_client_token":[CoreManager instagramLoginService].clientInstagramToken};
    [self sendLoginOrregisterRequest:userInfo loginType:STLoginRequestTypeInstagram];
}

@end

//
//  STFacebookShareController.m
//  Status
//
//  Created by Cosmin Andrus on 2/27/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STFacebookController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "STWebServiceController.h"
#import "STConstants.h"
#import "STFlowTemplateViewController.h"
#import "KeychainItemWrapper.h"
#import "STImageCacheController.h"
#import "AppDelegate.h"
#import "STLocationManager.h"
#import "STChatController.h"

#import <MobileAppTracker/MobileAppTracker.h>
#import <AdSupport/AdSupport.h>
#import "STCoreDataManager.h"
#import <Crashlytics/Crashlytics.h>

@implementation STFacebookController
+(STFacebookController *) sharedInstance{
    static STFacebookController *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

-(id)init{
    self = [super init];
    if (self) {
        
        _loginButton = [[FBLoginView alloc] initWithReadPermissions:@[@"public_profile", @"email"/*, @"user_likes"*/]];
        _loginButton.defaultAudience = FBSessionDefaultAudienceEveryone;
        [_loginButton setFrame:CGRectMake(50, 0, 218, 46)];
        [_loginButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        _loginButton.delegate = self;
         
    }
    return self;
}

-(NSString *) stringFromDict:(NSDictionary *) dict{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
        return @"";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

-(void) shareImageWithData:(NSData *) imgData andCompletion:(facebookCompletion) completion{
     NSDictionary *dictPrivacy = [NSDictionary dictionaryWithObjectsAndKeys:@"CUSTOM",@"value", @"ALL_FRIENDS", @"friends", nil];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [NSString stringWithFormat:@"what's YOUR status? via %@",STInviteLink] ,@"message",
                                   [self stringFromDict:dictPrivacy],@"privacy",
                                   @"STATUS", @"title",
                                   @"what's YOUR status?", @"description",
                                   @"http://getstatusapp.co/",@"link",
                                   nil];
    
    [params setValue:[UIImage imageWithData:imgData] forKey:@"source"];
    
    FBRequest *request = [FBRequest requestWithGraphPath:@"me/photos" parameters:params HTTPMethod:@"POST"];
    
    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
    
    [connection addRequest:request completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        completion(result, error);
    }];
    
    [connection start];
}

#pragma mark - Facebook DelegatesFyou

-(void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user{
    if (user[@"email"]==nil) {
        [[[UIAlertView alloc] initWithTitle:@"Permission Error" message:@"You need to grant access to email address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        
        return;
    }

    if ([STWebServiceController sharedInstance].isPerformLoginOrRegistration==FALSE) {
        [STWebServiceController sharedInstance].isPerformLoginOrRegistration = TRUE;
        [self loginOrRegistrationWithUser:user];
    }
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    if (self.logoutDelegate&&[self.logoutDelegate respondsToSelector:@selector(facebookControllerDidLoggedOut)]) {
        [self.logoutDelegate performSelector:@selector(facebookControllerDidLoggedOut)];
    }
    //[self deleteAccessToken];
    [NSObject cancelPreviousPerformRequestsWithTarget:[STLocationManager sharedInstance] selector:@selector(restartLocationManager) object:nil];
    [[STLocationManager sharedInstance] stopLocationUpdates];
    [[STLocationManager sharedInstance] setLatestLocation:nil];
    [[STImageCacheController sharedInstance] cleanTemporaryFolder];
    [[STCoreDataManager sharedManager] cleanLocalDataBase];
    
}

-(void) UDSetValue:(NSString *) value forKey:(NSString *) key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setValue:value forKey:key];
    [ud synchronize];
}

-(NSString *) getUDValueForKey:(NSString *) key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud valueForKey:key];
    
}
-(void)loadTokenFromKeyChain {
    KeychainItemWrapper *keychainWrapperAccessToken = [[KeychainItemWrapper alloc] initWithIdentifier:@"STUserAuthToken" accessGroup:nil];
    [STWebServiceController sharedInstance].accessToken = [keychainWrapperAccessToken objectForKey:(__bridge id)(kSecValueData)];
    //[[STLocationManager sharedInstance] startLocationUpdates];
    NSLog(@"Loaded Access Token: %@",[STWebServiceController sharedInstance].accessToken);
}

-(void)deleteAccessToken {
    KeychainItemWrapper *keychainWrapperAccessToken = [[KeychainItemWrapper alloc] initWithIdentifier:@"STUserAuthToken" accessGroup:nil];
    [keychainWrapperAccessToken resetKeychainItem];
    [STWebServiceController sharedInstance].accessToken = nil;
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

-(void) loginOrRegistrationWithUser:(id<FBGraphUser>)user{
    NSString *userIdentifier = user[@"email"]; //user[@"id"];
    [self UDSetValue:userIdentifier forKey:LOGGED_EMAIL];
    
    __weak STFacebookController *weakSelf = self;
    FBRequest *pic = [FBRequest requestForGraphPath:@"me/?fields=picture.type(large)"];
    [pic startWithCompletionHandler:^(FBRequestConnection *connection,
                                      id result,
                                      NSError *error) {
        if (error!=nil) {
            if (weakSelf.delegate&&[weakSelf.delegate respondsToSelector:@selector(facebookControllerDidLoggedOut)]) {
                [weakSelf.delegate performSelector:@selector(facebookControllerDidLoggedOut)];
            }
            //[self deleteAccessToken];
            [[STImageCacheController sharedInstance] cleanTemporaryFolder];
            [STWebServiceController sharedInstance].isPerformLoginOrRegistration = false;
            return ;
        }
        NSDictionary *resultDic = (NSDictionary<FBGraphUser> *) result;
        
        //weakSelf.currentUserPhotoLink = resultDic[@"picture"][@"data"][@"url"];
        //weakSelf.currentUserName = user[@"name"];
        
        __block NSString *photoLink = resultDic[@"picture"][@"data"][@"url"];
        __block NSString *userName = user[@"name"];
        [weakSelf UDSetValue:photoLink forKey:PHOTO_LINK];
        [weakSelf UDSetValue:userName  forKey:USER_NAME];

        [[STWebServiceController sharedInstance] loginUserWithInfo:@{@"email":userIdentifier,@"fb_token":[[[FBSession activeSession] accessTokenData] accessToken],@"facebook_image_link":photoLink,@"full_name":userName} withCompletion:^(NSDictionary *response) {
            if ([response[@"status_code"] integerValue]==STWebservicesNeedRegistrationCod) {

                [[STWebServiceController sharedInstance] registerUserWithInfo:@{@"full_name":userName, @"email":userIdentifier,@"facebook_image_link":photoLink,@"fb_token":[[[FBSession activeSession] accessTokenData] accessToken],@"phone_number":@""} withCompletion:^(NSDictionary *response) {
                    
                    if ([response[@"status_code"] integerValue] ==STWebservicesSuccesCod) {
                        [STWebServiceController sharedInstance].accessToken = response[@"token"];
                        [weakSelf UDSetValue:userIdentifier forKey:LOGGED_EMAIL];
                        [[STChatController sharedInstance] forceReconnect];
                        [[STLocationManager sharedInstance] startLocationUpdates];
                        [weakSelf saveAccessToken:response[@"token"]];
                        [self requestRemoteNotificationAccess];
                        weakSelf.currentUserId = response[@"user_id"];
                        [weakSelf setUpCrashlyticsForUserId:response[@"user_id"] andEmail:userIdentifier andUserName:userName];
                        [weakSelf announceDelegate];
                        [weakSelf measureRegister];
                    }
                    else
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong with the registration." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alert show];
                        [STWebServiceController sharedInstance].isPerformLoginOrRegistration=FALSE;
                    }
                    
                } andErrorCompletion:^(NSError *error) {
                    [STWebServiceController sharedInstance].isPerformLoginOrRegistration=FALSE;
                }];
                
            }
            else if ([response[@"status_code"] integerValue]==STWebservicesSuccesCod){
                [weakSelf setTrackerAsExistingUser];
                [STWebServiceController sharedInstance].accessToken = response[@"token"];
                [weakSelf UDSetValue:userIdentifier forKey:LOGGED_EMAIL];
                [[STChatController sharedInstance] forceReconnect];
                [[STLocationManager sharedInstance] startLocationUpdates];
                [weakSelf saveAccessToken:response[@"token"]];
                weakSelf.currentUserId = response[@"user_id"];
                [weakSelf setUpCrashlyticsForUserId:response[@"user_id"] andEmail:userIdentifier andUserName:response[@"user_name"]];
                [self requestRemoteNotificationAccess];
                [weakSelf announceDelegate];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong on login." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [STWebServiceController sharedInstance].isPerformLoginOrRegistration=FALSE;
            }
        } andErrorCompletion:^(NSError *error) {
            [STWebServiceController sharedInstance].isPerformLoginOrRegistration=FALSE;
        }];
        
    }];
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        [_delegate facebookControllerSessionExpired];
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    
    [self UDSetValue:nil forKey:LOGGED_EMAIL];
}

-(void) announceDelegate{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(facebookControllerDidLoggedIn)]) {
        [self.delegate performSelector:@selector(facebookControllerDidLoggedIn)];
    }
}

- (void)setTrackerAsExistingUser {
    [MobileAppTracker setExistingUser:YES];
    [MobileAppTracker measureAction:@"login"];
}

- (void)measureRegister {
    [MobileAppTracker measureAction:@"registration"];
}

static const UIRemoteNotificationType REMOTE_NOTIFICATION_TYPES_REQUIRED = UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge;
static const UIUserNotificationType USER_NOTIFICATION_TYPES_REQUIRED = UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge;

- (void)requestRemoteNotificationAccess;
{
    bool isIOS8OrGreater = [[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)];
    if (!isIOS8OrGreater)
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:REMOTE_NOTIFICATION_TYPES_REQUIRED];
        return;
    }
    
    UIUserNotificationSettings* requestedSettings = [UIUserNotificationSettings settingsForTypes:USER_NOTIFICATION_TYPES_REQUIRED categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:requestedSettings];
    
    
    //get settings from server
    [self getUserSettingsFromServer];
}

- (void)getUserSettingsFromServer {
    [[STWebServiceController sharedInstance] getUserSettingsWithCompletion:^(NSDictionary *response) {
        NSDictionary * settingsDict = response[@"data"];
        [[NSUserDefaults standardUserDefaults] setObject:settingsDict forKey:STSettingsDictKey];

    } andErrorCompletion:^(NSError *error) {
        NSLog(@"settings error: %@", error.localizedDescription);
    }];
}

@end

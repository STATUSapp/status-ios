//
//  STFacebookShareController.h
//  Status
//
//  Created by Cosmin Andrus on 2/27/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

#define USER_NAME       @"logged_user_name"

@protocol FacebookControllerDelegate <NSObject>

-(void) facebookControllerDidLoggedIn;
-(void) facebookControllerDidRegister;
-(void) facebookControllerDidLoggedOut;
-(void) facebookControllerSessionExpired;

@end

typedef void (^facebookCompletion)(id result, NSError *error);
@interface STFacebookLoginController : NSObject<FBLoginViewDelegate>
+(STFacebookLoginController *) sharedInstance;
@property (nonatomic, strong) id <FacebookControllerDelegate> delegate;
@property (nonatomic, strong) id <FacebookControllerDelegate> logoutDelegate;
@property (nonatomic, strong) FBLoginView *loginButton;
@property (nonatomic, strong) NSString *currentUserId;
-(void) shareImageWithData:(NSData *) imgData description:(NSString *)description andCompletion:(facebookCompletion) completion;
-(NSString *) getUDValueForKey:(NSString *) key;
-(void) UDSetValue:(NSString *) value forKey:(NSString *) key;
-(void)loadTokenFromKeyChain;
-(void)deleteAccessToken;
- (void)requestRemoteNotificationAccess;
@end

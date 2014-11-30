//
//  STFacebookShareController.h
//  Status
//
//  Created by Cosmin Andrus on 2/27/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

#define LOGGED_EMAIL    @"logged_email"
#define USER_NAME       @"logged_user_name"
#define PHOTO_LINK      @"logged_photo_link"

@protocol FacebookControllerDelegate <NSObject>

-(void) facebookControllerDidLoggedIn;
-(void) facebookControllerDidLoggedOut;
-(void) facebookControllerSessionExpired;

@end

typedef void (^facebookCompletion)(id result, NSError *error);
@interface STFacebookLoginController : NSObject<FBLoginViewDelegate>
+(STFacebookLoginController *) sharedInstance;
@property (nonatomic, strong) id <FacebookControllerDelegate> delegate;
@property (nonatomic, strong) id <FacebookControllerDelegate> logoutDelegate;
@property (nonatomic, strong) FBLoginView *loginButton;
//@property (nonatomic, strong) NSString *currentUserName;
//@property (nonatomic, strong) NSString *currentUserPhotoLink;
@property (nonatomic, strong) NSString *currentUserId;
-(void) shareImageWithData:(NSData *) imgData andCompletion:(facebookCompletion) completion;
-(NSString *) getUDValueForKey:(NSString *) key;
-(void) UDSetValue:(NSString *) value forKey:(NSString *) key;
-(void)loadTokenFromKeyChain;
-(void)deleteAccessToken;
- (void)requestRemoteNotificationAccess;
@end

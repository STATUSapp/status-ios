//
//  STFacebookShareController.h
//  Status
//
//  Created by Cosmin Andrus on 2/27/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "STUserProfile.h"
#import "STLoginView.h"

typedef void (^facebookCompletion)(id result, NSError *error);
@interface STLoginService : NSObject <STLoginViewDelegate>

@property (nonatomic, strong, readonly) STLoginView *loginView;

- (FBSDKLoginButton *)facebookLoginButton;

- (NSString *)currentUserUuid;
- (NSString *)currentUserFullName;
- (STProfileGender)currentUserGender;
- (STUserProfile *)userProfile;
- (void)startLoginIfPossible;
- (void)logoutManually;

//guest user
-(BOOL)isGuestUser;
@end

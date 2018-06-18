//
//  STLoginRequest.h
//  Status
//
//  Created by Cosmin Andrus on 19/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"
typedef NS_ENUM(NSUInteger, STLoginRequestType) {
    STLoginRequestTypeFacebook = 0,
    STLoginRequestTypeInstagram
};
@interface STLoginRequest : STBaseRequest

@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, assign) STLoginRequestType loginType;

+ (void)loginWithUserInfo:(NSDictionary*)userInfo
                loginType:(STLoginRequestType)loginType
           withCompletion:(STRequestCompletionBlock)completion
                  failure:(STRequestFailureBlock)failure;

@end

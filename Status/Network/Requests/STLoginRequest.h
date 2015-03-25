//
//  STLoginRequest.h
//  Status
//
//  Created by Cosmin Andrus on 19/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STLoginRequest : STBaseRequest
@property (nonatomic, strong) NSDictionary *userInfo;
+ (void)loginWithUserInfo:(NSDictionary*)userInfo
           withCompletion:(STRequestCompletionBlock)completion
                  failure:(STRequestFailureBlock)failure;

@end

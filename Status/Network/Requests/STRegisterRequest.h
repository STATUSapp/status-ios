//
//  STRegisterRequest.h
//  Status
//
//  Created by Cosmin Andrus on 19/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STRegisterRequest : STBaseRequest
@property (nonatomic, strong) NSDictionary *userInfo;
+ (void)registerWithUserInfo:(NSDictionary*)userInfo
              withCompletion:(STRequestCompletionBlock)completion
                     failure:(STRequestFailureBlock)failure;

@end

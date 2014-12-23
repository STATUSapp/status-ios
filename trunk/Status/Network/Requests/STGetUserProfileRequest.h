//
//  STGetUserProfile.h
//  Status
//
//  Created by Silviu Burlacu on 09/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STGetUserProfileRequest : STBaseRequest
@property (nonatomic, strong) NSString * userId;

+(void)getProfileForUserID:(NSString *)userId
            withCompletion:(STRequestCompletionBlock)completion
                   failure:(STRequestFailureBlock)failure;

@end

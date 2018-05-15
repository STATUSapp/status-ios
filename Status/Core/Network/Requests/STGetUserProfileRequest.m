//
//  STGetUserProfile.m
//  Status
//
//  Created by Silviu Burlacu on 09/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STGetUserProfileRequest.h"

@implementation STGetUserProfileRequest

+(void)getProfileForUserID:(NSString *)userId
            withCompletion:(STRequestCompletionBlock)completion
                   failure:(STRequestFailureBlock)failure {
    STGetUserProfileRequest *request = [STGetUserProfileRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.userId = userId;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetUserProfileRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        __strong STGetUserProfileRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
        params[@"user_id"] = strongSelf.userId;
        strongSelf.params = params;
        [[STNetworkQueueManager networkAPI] GET:url
                                   parameters:params
                                       progress:nil
                                      success:strongSelf.standardSuccessBlock
                                      failure:strongSelf.standardErrorBlock];
    };
    
    return executionBlock;
}

-(NSString *)urlString{
    return kGetUserProfile;
}

@end

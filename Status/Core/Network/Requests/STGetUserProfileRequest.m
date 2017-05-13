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
        
        NSString *url = [weakSelf urlString];
        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];
        params[@"user_id"] = weakSelf.userId;
        
        [[STNetworkQueueManager networkAPI] GET:url
                                   parameters:params
                                       progress:nil
                                      success:weakSelf.standardSuccessBlock
                                      failure:weakSelf.standardErrorBlock];
    };
    
    return executionBlock;
}

-(NSString *)urlString{
    return kGetUserProfile;
}

@end

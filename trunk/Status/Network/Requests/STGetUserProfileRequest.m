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
    [[STNetworkQueueManager sharedManager] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetUserProfileRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        NSString *url = [self urlString];
        NSMutableDictionary *params = [self getDictParamsWithToken];
        params[@"user_id"] = weakSelf.userId;
        
        [[STNetworkManager sharedManager] GET:url
                                   parameters:params
                                      success:weakSelf.standardSuccessBlock
                                      failure:weakSelf.standardErrorBlock];
    };
    
    return executionBlock;
}

-(NSString *)urlString{
    return kGetUserProfile;
}

@end

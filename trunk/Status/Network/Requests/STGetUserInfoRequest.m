//
//  STGetUserInfoRequest.m
//  Status
//
//  Created by Cosmin Andrus on 30/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STGetUserInfoRequest.h"

@implementation STGetUserInfoRequest
+ (void)getInfoForUser:(NSString *)userId
              completion:(STRequestCompletionBlock)completion
                 failure:(STRequestFailureBlock)failure{
    
    STGetUserInfoRequest *request = [STGetUserInfoRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.userId = userId;
    [[STNetworkQueueManager sharedManager] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetUserInfoRequest *weakSelf = self;
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
    return kGetUserInfo;
}
@end

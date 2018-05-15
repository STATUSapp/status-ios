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
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetUserInfoRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        __strong STGetUserInfoRequest *strongSelf = weakSelf;
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
    return kGetUserInfo;
}
@end

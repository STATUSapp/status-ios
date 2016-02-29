//
//  STGetUserSettingsRequest.m
//  Status
//
//  Created by Cosmin Andrus on 30/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STGetUserSettingsRequest.h"

@implementation STGetUserSettingsRequest
+ (void)getUserSettingsWithCompletion:(STRequestCompletionBlock)completion
                              failure:(STRequestFailureBlock)failure{
    
    STGetUserSettingsRequest *request = [STGetUserSettingsRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetUserSettingsRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        NSString *url = [weakSelf urlString];
        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];
        [[STNetworkManager sharedManager] GET:url
                                   parameters:params
                                      success:weakSelf.standardSuccessBlock
                                      failure:weakSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kGetUserSettings;
}
@end

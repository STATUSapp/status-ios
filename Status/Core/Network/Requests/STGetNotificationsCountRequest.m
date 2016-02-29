//
//  STGetNotificationsCountRequest.m
//  Status
//
//  Created by Cosmin Andrus on 30/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STGetNotificationsCountRequest.h"

@implementation STGetNotificationsCountRequest
+ (void)getNotificationsCountWithCompletion:(STRequestCompletionBlock)completion
                                    failure:(STRequestFailureBlock)failure{
    
    STGetNotificationsCountRequest *request = [STGetNotificationsCountRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetNotificationsCountRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        NSString *url = [self urlString];
        NSMutableDictionary *params = [self getDictParamsWithToken];
        
        [[STNetworkManager sharedManager] GET:url
                                   parameters:params
                                      success:weakSelf.standardSuccessBlock
                                      failure:weakSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kGetUnreadNotificationsCount;
}
@end

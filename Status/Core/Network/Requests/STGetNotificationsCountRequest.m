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
        
        __strong STGetNotificationsCountRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
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
    return kGetUnreadNotificationsCount;
}
@end

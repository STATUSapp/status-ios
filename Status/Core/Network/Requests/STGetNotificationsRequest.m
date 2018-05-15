//
//  STGetNotificationsRequest.m
//  Status
//
//  Created by Cosmin Andrus on 30/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STGetNotificationsRequest.h"

@implementation STGetNotificationsRequest
+ (void)getNotificationsWithCompletion:(STRequestCompletionBlock)completion
                               failure:(STRequestFailureBlock)failure{
    
    STGetNotificationsRequest *request = [STGetNotificationsRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetNotificationsRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        __strong STGetNotificationsRequest *strongSelf = weakSelf;
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
    return kGetNotifications;
}
@end

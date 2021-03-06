//
//  STUnseenPostsCountRequest.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 01/06/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STUnseenPostsCountRequest.h"

@implementation STUnseenPostsCountRequest
+ (void)getUnseenCountersWithCompletion:(STRequestCompletionBlock)completion
                                failure:(STRequestFailureBlock)failure{
    
    STUnseenPostsCountRequest *request = [STUnseenPostsCountRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STUnseenPostsCountRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        __strong STUnseenPostsCountRequest *strongSelf = weakSelf;
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
    return kUnseenPostsCount;
}
@end

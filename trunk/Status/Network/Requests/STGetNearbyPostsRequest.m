//
//  STGetNearbyPostsRequest.m
//  Status
//
//  Created by Cosmin Andrus on 27/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STGetNearbyPostsRequest.h"

@implementation STGetNearbyPostsRequest
+ (void)getNearbyPostsWithOffset:(NSInteger)offset
                  withCompletion:(STRequestCompletionBlock)completion
                         failure:(STRequestFailureBlock)failure{
    
    STGetNearbyPostsRequest *request = [STGetNearbyPostsRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.offset = offset;
    [[STNetworkQueueManager sharedManager] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetNearbyPostsRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        NSString *url = [self urlString];
        NSMutableDictionary *params = [self getDictParamsWithToken];
        params[@"limit"] = @(kPostsLimit);
        params[@"offset"] = @(weakSelf.offset);
        
        [[STNetworkManager sharedManager] GET:url
                                    parameters:params
                                       success:weakSelf.standardSuccessBlock
                                       failure:weakSelf.standardErrorBlock];
    };
    
    return executionBlock;
}

-(NSString *)urlString{
    return kGetNearbyPosts;
}
@end

//
//  STGetUserPostsRequest.m
//  Status
//
//  Created by Cosmin Andrus on 27/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STGetUserPostsRequest.h"

@implementation STGetUserPostsRequest
+ (void)getPostsForUser:(NSString *)userId
             withOffset:(NSInteger)offset
         withCompletion:(STRequestCompletionBlock)completion
                failure:(STRequestFailureBlock)failure{
    
    STGetUserPostsRequest *request = [STGetUserPostsRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.userId = userId;
    request.offset = offset;
    [[STNetworkQueueManager sharedManager] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetUserPostsRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        NSString *url = [self urlString];
        NSMutableDictionary *params = [self getDictParamsWithToken];
        params[@"limit"] = @(kPostsLimit);
        params[@"offset"] = @(weakSelf.offset);
        params[@"user_id"] = weakSelf.userId;
        
        [[STNetworkManager sharedManager] GET:url
                                    parameters:params
                                       success:weakSelf.standardSuccessBlock
                                       failure:weakSelf.standardErrorBlock];
    };
    
    return executionBlock;
}

-(NSString *)urlString{
    return kGetUserPosts;
}
@end

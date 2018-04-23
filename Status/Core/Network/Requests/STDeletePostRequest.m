//
//  STDeletePostRequest.m
//  Status
//
//  Created by Cosmin Andrus on 30/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STDeletePostRequest.h"

@implementation STDeletePostRequest
+ (void)deletePost:(NSString *)postId
    withCompletion:(STRequestCompletionBlock)completion
           failure:(STRequestFailureBlock)failure{
    
    STDeletePostRequest *request = [STDeletePostRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.postId = postId;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STDeletePostRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        NSString *url = [self urlString];
        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];
        params[@"post_id"] = weakSelf.postId;
        weakSelf.params = params;
        [[STNetworkQueueManager networkAPI] POST:url
                                   parameters:params
                                        progress:nil
                                      success:weakSelf.standardSuccessBlock
                                      failure:weakSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kDeletePost;
}

@end

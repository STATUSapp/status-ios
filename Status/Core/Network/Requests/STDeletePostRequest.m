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
        
        __strong STDeletePostRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
        params[@"post_id"] = strongSelf.postId;
        strongSelf.params = params;
        [[STNetworkQueueManager networkAPI] POST:url
                                   parameters:params
                                        progress:nil
                                      success:strongSelf.standardSuccessBlock
                                      failure:strongSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kDeletePost;
}

@end

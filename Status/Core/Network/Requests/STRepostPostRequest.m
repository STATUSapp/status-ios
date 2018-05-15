//
//  STRepostPostRequest.m
//  Status
//
//  Created by Cosmin Andrus on 23/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STRepostPostRequest.h"

@implementation STRepostPostRequest
+ (void)reportPostWithId:(NSString *)postId
          withCompletion:(STRequestCompletionBlock)completion
                 failure:(STRequestFailureBlock)failure{
    
    STRepostPostRequest *request = [STRepostPostRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.postId = postId;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STRepostPostRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        __strong STRepostPostRequest *strongSelf = weakSelf;
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
    return kReport_Post;
}
@end

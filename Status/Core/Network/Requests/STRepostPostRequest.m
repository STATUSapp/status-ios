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
        
        NSString *url = [self urlString];
        NSMutableDictionary *params = [self getDictParamsWithToken];
        params[@"post_id"] = weakSelf.postId;
        
        [[STNetworkQueueManager networkAPI] POST:url
                                    parameters:params
                                        progress:nil
                                       success:weakSelf.standardSuccessBlock
                                       failure:weakSelf.standardErrorBlock];
        
    };
    
    return executionBlock;
}

-(NSString *)urlString{
    return kReport_Post;
}
@end

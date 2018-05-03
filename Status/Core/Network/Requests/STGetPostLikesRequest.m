//
//  STGetPostLikesRequest.m
//  Status
//
//  Created by Cosmin Andrus on 30/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STGetPostLikesRequest.h"

@implementation STGetPostLikesRequest
+ (void)getPostLikes:(NSString*)postId
      withCompletion:(STRequestCompletionBlock)completion
             failure:(STRequestFailureBlock)failure{
    
    STGetPostLikesRequest *request = [STGetPostLikesRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.postId = postId;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetPostLikesRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        __strong STGetPostLikesRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
        params[@"post_id"] = strongSelf.postId;
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
    return kGetPostLikes;
}
@end

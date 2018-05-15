//
//  STGetPostDetails.m
//  Status
//
//  Created by Cosmin Andrus on 30/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STGetPostDetailsRequest.h"

@implementation STGetPostDetailsRequest
+ (void)getPostDetails:(NSString*)postId
        withCompletion:(STRequestCompletionBlock)completion
               failure:(STRequestFailureBlock)failure{
    
    STGetPostDetailsRequest *request = [STGetPostDetailsRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.postId = postId;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetPostDetailsRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        __strong STGetPostDetailsRequest *strongSelf = weakSelf;
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
    return kGetPost;
}
@end

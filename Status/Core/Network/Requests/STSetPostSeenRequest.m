//
//  STSetPostSeenRequest.m
//  Status
//
//  Created by Cosmin Andrus on 27/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STSetPostSeenRequest.h"

@implementation STSetPostSeenRequest
+ (void)setPostSeen:(NSString*)postId
     withCompletion:(STRequestCompletionBlock)completion
            failure:(STRequestFailureBlock)failure{
    
    STSetPostSeenRequest *request = [STSetPostSeenRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.postId = postId;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STSetPostSeenRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        NSString *url = [self urlString];
        NSMutableDictionary *params = [self getDictParamsWithToken];
        params[@"post_id"] = weakSelf.postId;
        
        [[STNetworkQueueManager networkAPI] POST:url
                                    parameters:params
                                       success:weakSelf.standardSuccessBlock
                                       failure:weakSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kSetPostSeen;
}
@end

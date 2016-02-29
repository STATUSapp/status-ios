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
        
        NSString *url = [self urlString];
        NSMutableDictionary *params = [self getDictParamsWithToken];
        params[@"post_id"] = weakSelf.postId;
        
        [[STNetworkManager sharedManager] GET:url
                                    parameters:params
                                       success:weakSelf.standardSuccessBlock
                                       failure:weakSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kGetPost;
}
@end

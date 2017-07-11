//
//  STUpdatePostCaptionRequest.m
//  Status
//
//  Created by Cosmin Andrus on 1/14/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STUpdatePostCaptionRequest.h"

@implementation STUpdatePostCaptionRequest
+ (void)setPostCaption:(NSString *)capion
             forPostId:(NSString *)postId
              withCompletion:(STRequestCompletionBlock)completion
                     failure:(STRequestFailureBlock)failure{
    
    STUpdatePostCaptionRequest *request = [STUpdatePostCaptionRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.postId = postId;
    request.caption = capion;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STUpdatePostCaptionRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        NSString *url = [self urlString];
        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];
        params[@"post_id"] = weakSelf.postId;
        params[@"caption"] = weakSelf.caption;
        [[STNetworkQueueManager networkAPI] POST:url
                                    parameters:params
                                        progress:nil
                                       success:weakSelf.standardSuccessBlock
                                       failure:weakSelf.standardErrorBlock];
        
    };
    
    return executionBlock;
}

-(NSString *)urlString{
    return kUpdatePhotoCaption;
}
@end

//
//  STGetTopPost.m
//  Status
//
//  Created by Cosmin Andrus on 05/08/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STGetTopPost.h"

@interface STGetTopPost ()

@property (nonatomic, strong) NSString *postId;
@property (nonatomic, strong) NSString *topId;

@end

@implementation STGetTopPost
+ (void)getTopPostForPostId:(NSString*)postId
                   andTopId:(NSString *)topId
      withCompletion:(STRequestCompletionBlock)completion
             failure:(STRequestFailureBlock)failure{
    
    STGetTopPost *request = [STGetTopPost new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.postId = postId;
    request.topId = topId;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetTopPost *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        __strong STGetTopPost *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
        params[@"post_id"] = strongSelf.postId;
        params[@"top_id"] = strongSelf.topId;
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
    return kGetTopPost;
}

@end

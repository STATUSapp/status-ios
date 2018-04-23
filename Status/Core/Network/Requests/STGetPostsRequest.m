//
//  STGetPostsRequest.m
//  Status
//
//  Created by Cosmin Andrus on 19/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STGetPostsRequest.h"
@implementation STGetPostsRequest
+ (void)getPostsWithOffset:(NSInteger)offset
                  flowType:(NSInteger)flowType
              withCompletion:(STRequestCompletionBlock)completion
                     failure:(STRequestFailureBlock)failure{
    
    STGetPostsRequest *request = [STGetPostsRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.offset = offset;
    request.flowType = flowType;
    [[CoreManager networkService] addToQueueTop:request];
}

+ (void)getPostsWithOffset:(NSInteger)offset
                  flowType:(NSInteger)flowType
                   hashtag:(NSString *)hashtag
            withCompletion:(STRequestCompletionBlock)completion
                   failure:(STRequestFailureBlock)failure{
    
    STGetPostsRequest *request = [STGetPostsRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.offset = offset;
    request.flowType = flowType;
    request.hashtag = hashtag;
    [[CoreManager networkService] addToQueueTop:request];
}


+ (void)getPostsWithOffset:(NSInteger)offset
                  flowType:(NSInteger)flowType
                 timeFrame:(NSString *)timeframe
                    gender:(NSString *)gender
            withCompletion:(STRequestCompletionBlock)completion
                   failure:(STRequestFailureBlock)failure{
    
    STGetPostsRequest *request = [STGetPostsRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.offset = offset;
    request.flowType = flowType;
    request.timeframe = timeframe;
    request.gender = gender;
    [[CoreManager networkService] addToQueueTop:request];
}


- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetPostsRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        NSString *url = [self urlString];
        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];

        params[@"limit"] = @(kPostsLimit);
        params[@"offset"] = @(weakSelf.offset);
        
        //filters for popular flow
        if (weakSelf.flowType == STFlowTypePopular ||
            weakSelf.flowType == STFlowTypeRecent) {
            if (weakSelf.timeframe) {
                params[@"timeframe"] = weakSelf.timeframe;
            }
            if (weakSelf.gender) {
                params[@"gender"] = weakSelf.gender;
            }
            else{
                params[@"gender"] = [NSNumber numberWithBool:FALSE];
            }
        }
        if (weakSelf.flowType == STFlowTypeHasttag) {
            params[@"hashtag"] = weakSelf.hashtag;
        }
        weakSelf.params = params;
        [[STNetworkQueueManager networkAPI] GET:url
                                    parameters:params
                                       progress:nil
                                       success:weakSelf.standardSuccessBlock
                                       failure:weakSelf.standardErrorBlock];
        
    };
    
    return executionBlock;
}

-(NSString *)urlString{
    NSString *url = kGetPosts;
    if (self.flowType == STFlowTypeRecent) {
        url = kGetRecentPosts;
    }else if (self.flowType == STFlowTypeHome){
        url = kGetHomePosts;
    }else if (self.flowType == STFlowTypeHasttag){
        url = kGetPostsByHashTag;
    }
    return url;
}
@end

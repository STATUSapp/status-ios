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
                     topId:(NSString *)topId
            withCompletion:(STRequestCompletionBlock)completion
                   failure:(STRequestFailureBlock)failure{
    
    STGetPostsRequest *request = [STGetPostsRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.offset = offset;
    request.flowType = flowType;
    request.topId = topId;
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
        
        __strong STGetPostsRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];

        params[@"limit"] = @(kPostsLimit);
        params[@"offset"] = @(strongSelf.offset);
        
        //filters for popular flow
        if (strongSelf.flowType == STFlowTypePopular ||
            strongSelf.flowType == STFlowTypeRecent) {
            if (strongSelf.timeframe) {
                params[@"timeframe"] = strongSelf.timeframe;
            }
            if (strongSelf.gender) {
                params[@"gender"] = strongSelf.gender;
            }
            else{
                params[@"gender"] = [NSNumber numberWithBool:FALSE];
            }
        }
        if (strongSelf.flowType == STFlowTypeHasttag) {
            params[@"hashtag"] = strongSelf.hashtag;
        }
        
        if (strongSelf.flowType == STFlowTypeTop) {
            params[@"top_id"] = strongSelf.topId;
        }
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
    NSString *url = kGetPosts;
    if (self.flowType == STFlowTypeRecent) {
        url = kGetRecentPosts;
    }else if (self.flowType == STFlowTypeHome){
        url = kGetHomePosts;
    }else if (self.flowType == STFlowTypeHasttag){
        url = kGetPostsByHashTag;
    }else if (self.flowType == STFlowTypeTop){
        url = kGetPostsByTop;
    }
    return url;
}
@end

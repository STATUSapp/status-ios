//
//  STGetSimilarProductsRequest.m
//  Status
//
//  Created by Cosmin Andrus on 28/02/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STGetSimilarProductsRequest.h"

@interface STGetSimilarProductsRequest ()

@property (nonatomic, strong) NSString *postId;
@property (nonatomic, strong) NSString *suggestionId;


@end

@implementation STGetSimilarProductsRequest
+ (void)getSimilarProductsForPostId:(NSString *)postId
                       suggestionId:(NSString *)suggestionId
                      andCompletion:(STRequestCompletionBlock)completion
                            failure:(STRequestFailureBlock)failure{
    
    STGetSimilarProductsRequest *request = [STGetSimilarProductsRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.postId = postId;
    request.suggestionId = suggestionId;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetSimilarProductsRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        __strong STGetSimilarProductsRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
        if (strongSelf.postId) {
            params[@"post_id"] = strongSelf.postId;
        }
        if (strongSelf.suggestionId) {
            params[@"suggestion_id"] = strongSelf.suggestionId;
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
    return kGetSimilarProducts;
}

@end

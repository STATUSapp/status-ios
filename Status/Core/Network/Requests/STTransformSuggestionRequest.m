//
//  STTransformSuggestionRequest.m
//  Status
//
//  Created by Cosmin Andrus on 18/05/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STTransformSuggestionRequest.h"

@interface STTransformSuggestionRequest ()

@property (nonatomic, strong) NSString *suggestionId;
@property (nonatomic, strong) NSString *postId;
@end

@implementation STTransformSuggestionRequest
+ (void)transformSuggestedProductId:(NSString *)suggestionId
                          forPostId:(NSString *)postId
                      andCompletion:(STRequestCompletionBlock)completion
                            failure:(STRequestFailureBlock)failure{
    
    STTransformSuggestionRequest *request = [STTransformSuggestionRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.suggestionId = suggestionId;
    request.postId = postId;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STTransformSuggestionRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        __strong STTransformSuggestionRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
        if (strongSelf.postId) {
            params[@"post_id"] = strongSelf.postId;
        }
        if (strongSelf.suggestionId) {
            params[@"suggestion_id"] = strongSelf.suggestionId;
        }
        
        strongSelf.params = params;
        [[STNetworkQueueManager networkAPI] POST:url
                                      parameters:params
                                        progress:nil
                                         success:strongSelf.standardSuccessBlock
                                         failure:strongSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kTransformSuggestion;
}

@end

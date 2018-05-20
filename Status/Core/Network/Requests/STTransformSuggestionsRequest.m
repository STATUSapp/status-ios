//
//  STTransformSuggestionRequest.m
//  Status
//
//  Created by Cosmin Andrus on 18/05/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STTransformSuggestionsRequest.h"
#import "STSuggestedProduct.h"

@interface STTransformSuggestionsRequest ()

@property (nonatomic, strong) NSArray <STSuggestedProduct *> *suggestions;
@property (nonatomic, strong) NSString *postId;
@end

@implementation STTransformSuggestionsRequest
+ (void)transformSuggestions:(NSArray<STSuggestedProduct *> *)suggestions
                   forPostId:(NSString *)postId
               andCompletion:(STRequestCompletionBlock)completion
                     failure:(STRequestFailureBlock)failure{
    
    STTransformSuggestionsRequest *request = [STTransformSuggestionsRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.suggestions = suggestions;
    request.postId = postId;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STTransformSuggestionsRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        __strong STTransformSuggestionsRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
        if (strongSelf.postId) {
            params[@"post_id"] = strongSelf.postId;
        }
        if (strongSelf.suggestions) {
            params[@"suggestion_ids"] = [strongSelf.suggestions valueForKey:@"uuid"];
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
    return kTransformSuggestions;
}

@end

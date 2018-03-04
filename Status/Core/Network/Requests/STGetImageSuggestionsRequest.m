//
//  STGetImageSuggestions.m
//  Status
//
//  Created by Cosmin Andrus on 28/02/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STGetImageSuggestionsRequest.h"

@interface STGetImageSuggestionsRequest()

@property (nonatomic, strong) NSString *suggestionsId;

@end

@implementation STGetImageSuggestionsRequest
+ (void)getImageSuggestionsForId:(NSString *)suggestionsId
                   andCompletion:(STRequestCompletionBlock)completion
                         failure:(STRequestFailureBlock)failure{
    
    STGetImageSuggestionsRequest *request = [STGetImageSuggestionsRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.suggestionsId = suggestionsId;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetImageSuggestionsRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        NSString *url = [weakSelf urlString];
        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];
        if (weakSelf.suggestionsId) {
            params[@"suggestions_id"] = weakSelf.suggestionsId;
        }        
        [[STNetworkQueueManager networkAPI] GET:url
                                     parameters:params
                                       progress:nil
                                        success:weakSelf.standardSuccessBlock
                                        failure:weakSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kGetImageSuggestions;
}

@end

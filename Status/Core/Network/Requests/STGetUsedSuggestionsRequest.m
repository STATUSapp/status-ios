//
//  STGetUsedSuggestions.m
//  Status
//
//  Created by Cosmin Andrus on 21/03/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STGetUsedSuggestionsRequest.h"

@implementation STGetUsedSuggestionsRequest
+ (void)getUsedSuggestionsEntitiesForCategory:(NSString *)categoryId
                            andCompletion:(STRequestCompletionBlock)completion
                                  failure:(STRequestFailureBlock)failure{
    
    STGetUsedSuggestionsRequest *request = [STGetUsedSuggestionsRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.categoryId = categoryId;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetUsedSuggestionsRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        NSString *url = [weakSelf urlString];
        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];
        params[@"category_id"] = weakSelf.categoryId;
        [[STNetworkQueueManager networkAPI] GET:url
                                     parameters:params
                                        success:weakSelf.standardSuccessBlock
                                        failure:weakSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kGetUsedSuggestions;
}

@end

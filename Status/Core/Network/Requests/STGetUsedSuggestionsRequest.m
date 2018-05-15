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
                                 andPageIndex:(NSInteger)pageIndex
                            andCompletion:(STRequestCompletionBlock)completion
                                  failure:(STRequestFailureBlock)failure{
    
    STGetUsedSuggestionsRequest *request = [STGetUsedSuggestionsRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.categoryId = categoryId;
    request.pageIndex = pageIndex;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetUsedSuggestionsRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        __strong STGetUsedSuggestionsRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
        if (strongSelf.categoryId) {
            params[@"category_id"] = strongSelf.categoryId;
        }
        params[@"pageSize"] = @(kCatalogDownloadPageSize);
        params[@"page"] = @(strongSelf.pageIndex);
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
    return kGetUsedSuggestions;
}

@end

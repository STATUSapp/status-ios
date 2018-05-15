//
//  STGetSuggestionsRequest.m
//  Status
//
//  Created by Cosmin Andrus on 21/03/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STGetSuggestionsRequest.h"

@implementation STGetSuggestionsRequest

+ (void)getSuggestionsEntitiesForCategory:(NSString *)categoryId
                               andBrandId:(NSString *)brandId
                             andPageIndex:(NSInteger)pageIndex
                            andCompletion:(STRequestCompletionBlock)completion
                       failure:(STRequestFailureBlock)failure{
    
    STGetSuggestionsRequest *request = [STGetSuggestionsRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.categoryId = categoryId;
    request.brandId = brandId;
    request.pageIndex = pageIndex;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetSuggestionsRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        __strong STGetSuggestionsRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
        params[@"category_id"] = strongSelf.categoryId;
        if (strongSelf.brandId) {
            params[@"brand_id"] = strongSelf.brandId;
        }else{
            params[@"brand_id"] = [NSNull null];
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
    return kGetSuggestions;
}



@end

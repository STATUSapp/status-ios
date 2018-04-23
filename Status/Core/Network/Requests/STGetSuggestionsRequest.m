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
        NSString *url = [weakSelf urlString];
        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];
        params[@"category_id"] = weakSelf.categoryId;
        if (weakSelf.brandId) {
            params[@"brand_id"] = weakSelf.brandId;
        }else{
            params[@"brand_id"] = [NSNull null];
        }
        params[@"pageSize"] = @(kCatalogDownloadPageSize);
        params[@"page"] = @(weakSelf.pageIndex);
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
    return kGetSuggestions;
}



@end

//
//  STGetCategories.m
//  Status
//
//  Created by Cosmin Andrus on 12/02/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STGetCatalogCategoriesRequest.h"

@implementation STGetCatalogCategoriesRequest
+ (void)getCatalogCategoriesForparentCategoryId:(NSString *)parentCategoryId
                                      pageIndex:(NSInteger)pageIndex
                                 withCompletion:(STRequestCompletionBlock)completion
                                        failure:(STRequestFailureBlock)failure{
    
    STGetCatalogCategoriesRequest *request = [STGetCatalogCategoriesRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.parentCategoryId = parentCategoryId;
    request.pageIndex = pageIndex;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetCatalogCategoriesRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        __strong STGetCatalogCategoriesRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];

        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
        params[@"root_category_id"] = strongSelf.parentCategoryId;
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
    return kGetCatalofCategories;
}

@end

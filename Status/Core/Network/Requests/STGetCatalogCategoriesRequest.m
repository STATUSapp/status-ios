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
//        NSString *url = [NSString stringWithFormat:@"%@/%@", [weakSelf urlString], weakSelf.parentCategoryId];
        NSString *url = [weakSelf urlString];

        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];
        params[@"root_category_id"] = weakSelf.parentCategoryId;
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
    return kGetCatalofCategories;
}

@end

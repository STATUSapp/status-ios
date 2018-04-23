//
//  STGetUsedCatalogCategoriesRequest.m
//  Status
//
//  Created by Cosmin Andrus on 21/03/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STGetUsedCatalogCategoriesRequest.h"

@implementation STGetUsedCatalogCategoriesRequest
+ (void)getUsedCatalogCategoriesAtPageIndex:(NSInteger)pageIndex
                             withCompletion:(STRequestCompletionBlock)completion
                                    failure:(STRequestFailureBlock)failure{
    
    STGetUsedCatalogCategoriesRequest *request = [STGetUsedCatalogCategoriesRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.pageIndex = pageIndex;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetUsedCatalogCategoriesRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        NSString *url = [weakSelf urlString];
        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];
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
    return kGetUsedCatalofCategories;
}

@end

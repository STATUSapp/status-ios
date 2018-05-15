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
        __strong STGetUsedCatalogCategoriesRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
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
    return kGetUsedCatalofCategories;
}

@end

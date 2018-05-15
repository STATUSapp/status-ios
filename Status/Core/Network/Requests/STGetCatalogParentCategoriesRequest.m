//
//  STGetCatalogParentCategories.m
//  Status
//
//  Created by Cosmin Andrus on 12/02/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STGetCatalogParentCategoriesRequest.h"

@implementation STGetCatalogParentCategoriesRequest
+ (void)getCatalogParentEntities:(STRequestCompletionBlock)completion
                              failure:(STRequestFailureBlock)failure{
    
    STGetCatalogParentCategoriesRequest *request = [STGetCatalogParentCategoriesRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetCatalogParentCategoriesRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        __strong STGetCatalogParentCategoriesRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
        params[@"pageSize"] = @(kCatalogDownloadPageSize);
        params[@"page"] = @(1);
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
    return kGetCatalogParentCategories;
}

@end

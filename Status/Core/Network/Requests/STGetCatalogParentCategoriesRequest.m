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
        NSString *url = [weakSelf urlString];
        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];
        [[STNetworkQueueManager networkAPI] GET:url
                                     parameters:params
                                       progress:nil
                                        success:weakSelf.standardSuccessBlock
                                        failure:weakSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kGetCatalogParentCategories;
}

@end

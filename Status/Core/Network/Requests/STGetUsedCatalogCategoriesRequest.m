//
//  STGetUsedCatalogCategoriesRequest.m
//  Status
//
//  Created by Cosmin Andrus on 21/03/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STGetUsedCatalogCategoriesRequest.h"

@implementation STGetUsedCatalogCategoriesRequest
+ (void)getUsedCatalogCategoriesWithCompletion:(STRequestCompletionBlock)completion
                                        failure:(STRequestFailureBlock)failure{
    
    STGetUsedCatalogCategoriesRequest *request = [STGetUsedCatalogCategoriesRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetUsedCatalogCategoriesRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        NSString *url = [weakSelf urlString];
        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];
        [[STNetworkQueueManager networkAPI] GET:url
                                     parameters:params
                                        success:weakSelf.standardSuccessBlock
                                        failure:weakSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kGetUsedCatalofCategories;
}

@end

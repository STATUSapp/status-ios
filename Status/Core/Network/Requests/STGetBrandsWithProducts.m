//
//  STGetBrandsWithProducts.m
//  Status
//
//  Created by Cosmin Andrus on 09/01/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STGetBrandsWithProducts.h"

@interface STGetBrandsWithProducts ()

@property (nonatomic, strong) NSString *categoryId;

@end

@implementation STGetBrandsWithProducts

+ (void)getBrandsWithProductsForCategoryId:(NSString *)categoryId
                  withCompletion:(STRequestCompletionBlock)completion
                         failure:(STRequestFailureBlock)failure{
    
    STGetBrandsWithProducts *request = [STGetBrandsWithProducts new];
    request.completionBlock = completion;
    request.categoryId = categoryId;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetBrandsWithProducts *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        NSString *url = [weakSelf urlString];
        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];
        params[@"category_id"] = weakSelf.categoryId;
        [[STNetworkQueueManager networkAPI] GET:url
                                     parameters:params
                                       progress:nil
                                        success:weakSelf.standardSuccessBlock
                                        failure:weakSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kGetBrandsWithProducts;
}

@end

//
//  STGetSimilarProductsRequest.m
//  Status
//
//  Created by Cosmin Andrus on 28/02/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STGetSimilarProductsRequest.h"

@interface STGetSimilarProductsRequest ()

@property (nonatomic, strong) NSString *productId;

@end

@implementation STGetSimilarProductsRequest
+ (void)getSimilarProductsForProductId:(NSString *)productId
                        andCompletion:(STRequestCompletionBlock)completion
                               failure:(STRequestFailureBlock)failure{
    
    STGetSimilarProductsRequest *request = [STGetSimilarProductsRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.productId = productId;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetSimilarProductsRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        NSString *url = [weakSelf urlString];
        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];
        if (weakSelf.productId) {
            params[@"product_id"] = weakSelf.productId;
        }
        [[STNetworkQueueManager networkAPI] GET:url
                                     parameters:params
                                       progress:nil
                                        success:weakSelf.standardSuccessBlock
                                        failure:weakSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kGetSimilarProducts;
}

@end

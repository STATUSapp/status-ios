//
//  STGetBrandsRequest.m
//  Status
//
//  Created by Cosmin Andrus on 12/02/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//


#import "STGetBrandsRequest.h"

@interface STGetBrandsRequest ()

@property (nonatomic, assign) NSInteger pageIndex;

@end

@implementation STGetBrandsRequest
+ (void)getBrandsEntitiesForPage:(NSInteger )pageIndex
                  withCompletion:(STRequestCompletionBlock)completion
                         failure:(STRequestFailureBlock)failure{
    
    STGetBrandsRequest *request = [STGetBrandsRequest new];
    request.completionBlock = completion;
    request.pageIndex = pageIndex;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetBrandsRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        __strong STGetBrandsRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
        params[@"pageSize"] = @(kCatalogBrandsPageSize);
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
    return kGetBrands;
}

@end

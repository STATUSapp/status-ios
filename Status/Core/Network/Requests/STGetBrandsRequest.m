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
        NSString *url = [weakSelf urlString];
        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];
        params[@"pageSize"] = @(kCatalogDownloadPageSize);
        params[@"page"] = @(weakSelf.pageIndex);
//        params[@"search"] = @"";
        [[STNetworkQueueManager networkAPI] GET:url
                                     parameters:params
                                       progress:nil
                                        success:weakSelf.standardSuccessBlock
                                        failure:weakSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kGetBrands;
}

@end

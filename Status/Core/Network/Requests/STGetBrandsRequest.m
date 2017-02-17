//
//  STGetBrandsRequest.m
//  Status
//
//  Created by Cosmin Andrus on 12/02/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STGetBrandsRequest.h"

@implementation STGetBrandsRequest
+ (void)getBrandsEntities:(STRequestCompletionBlock)completion
                         failure:(STRequestFailureBlock)failure{
    
    STGetBrandsRequest *request = [STGetBrandsRequest new];
    request.completionBlock = completion;
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
        [[STNetworkQueueManager networkAPI] GET:url
                                     parameters:params
                                        success:weakSelf.standardSuccessBlock
                                        failure:weakSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kGetBrands;
}

@end

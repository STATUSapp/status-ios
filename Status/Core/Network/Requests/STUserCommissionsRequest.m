//
//  STGetUserCommissions.m
//  Status
//
//  Created by Cosmin Andrus on 05/07/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STUserCommissionsRequest.h"
typedef NS_ENUM(NSUInteger, STUserCommission) {
    STUserCommissionGet = 0,
    STUserCommissionWithdrawn
};
@interface STUserCommissionsRequest ()

@property (nonatomic, assign)STUserCommission requestType;

@end

@implementation STUserCommissionsRequest
+ (void)getUserCommissionsWithCompletion:(STRequestCompletionBlock)completion
                                 failure:(STRequestFailureBlock)failure{
    
    STUserCommissionsRequest *request = [STUserCommissionsRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.requestType = STUserCommissionGet;
    [[CoreManager networkService] addToQueueTop:request];
}

+ (void)withdrawnUserCommissionsWithCompletion:(STRequestCompletionBlock)completion
                                       failure:(STRequestFailureBlock)failure{
    
    STUserCommissionsRequest *request = [STUserCommissionsRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.requestType = STUserCommissionWithdrawn;
    [[CoreManager networkService] addToQueueTop:request];
}


- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STUserCommissionsRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        NSString *url = [weakSelf urlString];
        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];
        if (weakSelf.requestType == STUserCommissionGet) {
            [[STNetworkQueueManager networkAPI] GET:url
                                         parameters:params
                                           progress:nil
                                            success:weakSelf.standardSuccessBlock
                                            failure:weakSelf.standardErrorBlock];
        }
        else
        {
            [[STNetworkQueueManager networkAPI] POST:url
                                          parameters:params
                                            progress:nil
                                             success:weakSelf.standardSuccessBlock
                                             failure:weakSelf.standardErrorBlock];
        }
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kUserCommissions;
}

@end

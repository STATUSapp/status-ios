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
        
        __strong STUserCommissionsRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
        strongSelf.params = params;
        if (strongSelf.requestType == STUserCommissionGet) {
            [[STNetworkQueueManager networkAPI] GET:url
                                         parameters:params
                                           progress:nil
                                            success:strongSelf.standardSuccessBlock
                                            failure:strongSelf.standardErrorBlock];
        }
        else
        {
            [[STNetworkQueueManager networkAPI] POST:url
                                          parameters:params
                                            progress:nil
                                             success:strongSelf.standardSuccessBlock
                                             failure:strongSelf.standardErrorBlock];
        }
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kUserCommissions;
}

@end

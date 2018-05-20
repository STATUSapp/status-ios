//
//  STDeleteAccountRequest.m
//  Status
//
//  Created by Cosmin Andrus on 20/05/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STDeleteAccountRequest.h"

@implementation STDeleteAccountRequest

+ (void)deleteAccountWithCompletion:(STRequestCompletionBlock)completion
                            failure:(STRequestFailureBlock)failure{
    
    STDeleteAccountRequest *request = [STDeleteAccountRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STDeleteAccountRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        __strong STDeleteAccountRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];        
        strongSelf.params = params;
        [[STNetworkQueueManager networkAPI] POST:url
                                      parameters:params
                                        progress:nil
                                         success:strongSelf.standardSuccessBlock
                                         failure:strongSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kDeleteAccount;
}

@end

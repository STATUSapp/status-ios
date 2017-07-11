//
//  STSetAPNTokenRequest.m
//  Status
//
//  Created by Cosmin Andrus on 30/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STSetAPNTokenRequest.h"

@implementation STSetAPNTokenRequest
+ (void)setAPNToken:(NSString*)apnToken
     withCompletion:(STRequestCompletionBlock)completion
            failure:(STRequestFailureBlock)failure{
    
    STSetAPNTokenRequest *request = [STSetAPNTokenRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.apnToken = apnToken;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STSetAPNTokenRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        NSString *url = [self urlString];
        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];
        params[@"apn_token"] = weakSelf.apnToken;
        
        [[STNetworkQueueManager networkAPI] POST:url
                                   parameters:params
                                        progress:nil
                                      success:weakSelf.standardSuccessBlock
                                      failure:weakSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kSetApnToken;
}
@end

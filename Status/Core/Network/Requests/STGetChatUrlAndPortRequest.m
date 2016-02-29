//
//  STGetChatUrlAndPortRequest.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 27/09/15.
//  Copyright © 2015 Andrus Cosmin. All rights reserved.
//

#import "STGetChatUrlAndPortRequest.h"

@implementation STGetChatUrlAndPortRequest
+ (void)getReconnectInfoWithCompletion:(STRequestCompletionBlock)completion
                            failure:(STRequestFailureBlock)failure{
    
    STGetChatUrlAndPortRequest *request = [STGetChatUrlAndPortRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetChatUrlAndPortRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        NSString *url = [weakSelf urlString];
        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];
        [[STNetworkManager sharedManager] GET:url
                                   parameters:params
                                      success:weakSelf.standardSuccessBlock
                                      failure:weakSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kGetHostnamePortChat;
}
@end

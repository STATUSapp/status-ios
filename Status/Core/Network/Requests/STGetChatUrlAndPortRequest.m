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
        
        __strong STGetChatUrlAndPortRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
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
    return kGetHostnamePortChat;
}
@end

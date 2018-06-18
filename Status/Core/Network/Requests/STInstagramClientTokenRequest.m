//
//  STInstagramTemporaryToken.m
//  Status
//
//  Created by Cosmin Andrus on 17/06/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STInstagramClientTokenRequest.h"

@implementation STInstagramClientTokenRequest

+ (void)getClientInstagramTokenWithCompletion:(STRequestCompletionBlock)completion
                            failure:(STRequestFailureBlock)failure{
    
    STInstagramClientTokenRequest *request = [STInstagramClientTokenRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STInstagramClientTokenRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        __strong STInstagramClientTokenRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        [[STNetworkQueueManager networkAPI] POST:url
                                      parameters:nil
                                        progress:nil
                                         success:strongSelf.standardSuccessBlock
                                         failure:strongSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kGetInstagramClientToken;
}
@end

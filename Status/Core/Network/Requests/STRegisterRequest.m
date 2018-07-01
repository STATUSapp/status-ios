//
//  STRegisterRequest.m
//  Status
//
//  Created by Cosmin Andrus on 19/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STRegisterRequest.h"

@implementation STRegisterRequest
+ (void)registerWithUserInfo:(NSDictionary*)userInfo
           withCompletion:(STRequestCompletionBlock)completion
                  failure:(STRequestFailureBlock)failure{
    
    STRegisterRequest *request = [STRegisterRequest new];
    request.authentication = YES;
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.userInfo = userInfo;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STRegisterRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        __strong STRegisterRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:strongSelf.userInfo];
        params[@"timezone"] = [strongSelf getTimeZoneOffsetFromGMT];
        params[@"app_version"] = [strongSelf getAppVersion];
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
    return kRegisterUser;
}
@end

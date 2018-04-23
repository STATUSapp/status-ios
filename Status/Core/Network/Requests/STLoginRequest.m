//
//  STLoginRequest.m
//  Status
//
//  Created by Cosmin Andrus on 19/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STLoginRequest.h"

@implementation STLoginRequest
+ (void)loginWithUserInfo:(NSDictionary*)userInfo
                           withCompletion:(STRequestCompletionBlock)completion
                                  failure:(STRequestFailureBlock)failure{
    
    STLoginRequest *request = [STLoginRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.userInfo = userInfo;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STLoginRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        NSString *url = [self urlString];
                
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:weakSelf.userInfo];
        params[@"timezone"] = [self getTimeZoneOffsetFromGMT];
        params[@"app_version"] = [self getAppVersion];
        weakSelf.params = params;
        [[STNetworkQueueManager networkAPI] POST:url
                                        parameters:params
                                        progress:nil
                                           success:weakSelf.standardSuccessBlock
                                           failure:weakSelf.standardErrorBlock];
    };
    
    return executionBlock;
}

-(NSString *)urlString{
    return kLoginUser;
}
@end

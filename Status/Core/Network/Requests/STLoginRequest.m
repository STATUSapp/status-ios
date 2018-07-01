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
                loginType:(STLoginRequestType)loginType
           withCompletion:(STRequestCompletionBlock)completion
                  failure:(STRequestFailureBlock)failure{
    
    STLoginRequest *request = [STLoginRequest new];
    request.authentication = YES;
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.userInfo = userInfo;
    request.loginType = loginType;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STLoginRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        __strong STLoginRequest *strongSelf = weakSelf;
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
    if (self.loginType == STLoginRequestTypeFacebook) {
        return kLoginUser;
    }else{
        return kInstagramLogin;
    }
}
@end

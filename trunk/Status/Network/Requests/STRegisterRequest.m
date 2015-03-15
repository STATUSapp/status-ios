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
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.userInfo = userInfo;
    [[STNetworkQueueManager sharedManager] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STRegisterRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        NSString *url = [self urlString];
                
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:weakSelf.userInfo];
        params[@"timezone"] = [self getTimeZoneOffsetFromGMT];
        params[@"app_version"] = [self getAppVersion];
        
        [[STNetworkManager sharedManager] POST:url
                                    parameters:params
                                       success:weakSelf.standardSuccessBlock
                                       failure:weakSelf.standardErrorBlock];
        
    };
    
    return executionBlock;
}

-(NSString *)urlString{
    return kRegisterUser;
}
@end

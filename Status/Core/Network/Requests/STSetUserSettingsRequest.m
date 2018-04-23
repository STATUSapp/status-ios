//
//  STSetUserSettingsRequest.m
//  Status
//
//  Created by Cosmin Andrus on 30/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STSetUserSettingsRequest.h"

@implementation STSetUserSettingsRequest
+ (void)setSettingsValue:(BOOL)value
                  forKey:(NSString *)key
          withCompletion:(STRequestCompletionBlock)completion
                 failure:(STRequestFailureBlock)failure{
    
    STSetUserSettingsRequest *request = [STSetUserSettingsRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.value = value;
    request.key = key;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STSetUserSettingsRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        NSString *url = [weakSelf urlString];
        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];
        params[@"value"] = @(weakSelf.value);
        params[@"key"] = weakSelf.key;
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
    return kSetUserSetting;
}

@end

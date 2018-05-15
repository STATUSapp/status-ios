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
        
        __strong STSetUserSettingsRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
        params[@"value"] = @(strongSelf.value);
        params[@"key"] = strongSelf.key;
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
    return kSetUserSetting;
}

@end

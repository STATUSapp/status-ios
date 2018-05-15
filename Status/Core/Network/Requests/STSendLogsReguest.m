//
//  STSendLogsReguest.m
//  Status
//
//  Created by Cosmin Andrus on 20/04/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STSendLogsReguest.h"

@interface STSendLogsReguest ()

@property (nonatomic, strong) NSDictionary *logs;

@end

@implementation STSendLogsReguest
+ (void)sendLogs:(NSDictionary *)logs
   andCompletion:(STRequestCompletionBlock)completion
         failure:(STRequestFailureBlock)failure{
    
    STSendLogsReguest *request = [STSendLogsReguest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.logs = logs;
    [[CoreManager networkService] addToQueue:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STSendLogsReguest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        __strong STSendLogsReguest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSMutableDictionary *logs = [@{} mutableCopy];
        [logs addEntriesFromDictionary:[strongSelf defaultLogsiOS]];
        [logs addEntriesFromDictionary:strongSelf.logs];
        NSMutableDictionary *params = [@{} mutableCopy];
        params[@"content"] = logs;
        [[STNetworkQueueManager networkAPI] POST:url
                                     parameters:params
                                       progress:nil
                                        success:strongSelf.standardSuccessBlock
                                        failure:strongSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kSendLogs;
}

- (NSDictionary *)defaultLogsiOS{
    return @{@"platform": @"iOS",
             @"version": [self getAppVersion]
             };
}

@end

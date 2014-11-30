//
//  STInviteUserToUploadRequest.m
//  Status
//
//  Created by Cosmin Andrus on 30/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STInviteUserToUploadRequest.h"

@implementation STInviteUserToUploadRequest
+ (void)inviteUserToUpload:(NSString *)userId
            withCompletion:(STRequestCompletionBlock)completion
                   failure:(STRequestFailureBlock)failure{
    
    STInviteUserToUploadRequest *request = [STInviteUserToUploadRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.userId = userId;
    [[STNetworkQueueManager sharedManager] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STInviteUserToUploadRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        NSString *url = [self urlString];
        NSMutableDictionary *params = [self getDictParamsWithToken];
        params[@"user_id"] = weakSelf.userId;
        [[STNetworkManager sharedManager] POST:url
                                    parameters:params
                                       success:weakSelf.standardSuccessBlock
                                       failure:weakSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kInviteToUpload;
}

@end

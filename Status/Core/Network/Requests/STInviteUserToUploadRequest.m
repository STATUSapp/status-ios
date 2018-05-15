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
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STInviteUserToUploadRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        __strong STInviteUserToUploadRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
        params[@"user_id"] = strongSelf.userId;
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
    return kInviteToUpload;
}

@end

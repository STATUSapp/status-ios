//
//  STGetFollowersRequest.m
//  Status
//
//  Created by Silviu Burlacu on 07/06/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STGetFollowersRequest.h"

@implementation STGetFollowersRequest
+ (void)getFollowersForUser:(NSString *)userID withOffset:(NSNumber *)offset
                   withCompletion:(STRequestCompletionBlock)completion
                          failure:(STRequestFailureBlock)failure{
    
    STGetFollowersRequest *request = [STGetFollowersRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.offset = offset;
    request.userID = userID;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetFollowersRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        __strong STGetFollowersRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
        params[@"offset"] = strongSelf.offset;
        params[@"limit"] = @(100);
        params[@"user_id"] = strongSelf.userID;
        strongSelf.params = params;
        [[STNetworkQueueManager networkAPI] GET:url
                                    parameters:params
                                       progress:nil
                                       success:strongSelf.standardSuccessBlock
                                       failure:strongSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return @"Get_Profile_Followers";
}
@end

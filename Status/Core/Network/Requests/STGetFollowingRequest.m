//
//  STGetFollowingRequest.m
//  Status
//
//  Created by Silviu Burlacu on 07/06/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STGetFollowingRequest.h"

@implementation STGetFollowingRequest
+ (void)getFollowingForUser:(NSString *)userID withOffset:(NSNumber *)offset
             withCompletion:(STRequestCompletionBlock)completion
                    failure:(STRequestFailureBlock)failure{
    
    STGetFollowingRequest *request = [STGetFollowingRequest new];
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
    __weak STGetFollowingRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        NSString *url = [weakSelf urlString];
        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];
        params[@"offset"] = weakSelf.offset;
        params[@"limit"] = @(100);
        params[@"user_id"] = weakSelf.userID;
        
        [[STNetworkQueueManager networkAPI] GET:url
                                    parameters:params
                                       progress:nil
                                       success:weakSelf.standardSuccessBlock
                                       failure:weakSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return @"Get_Profile_Following";
}
@end

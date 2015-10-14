//
//  STGetSuggestUsers.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 17/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STGetSuggestUsersRequest.h"

@implementation STGetSuggestUsersRequest
+ (void)getSuggestUsersForFollowType:(STFollowType)followType
                          withOffset:(NSNumber *)offset
                   withCompletion:(STRequestCompletionBlock)completion
                          failure:(STRequestFailureBlock)failure{
    
    STGetSuggestUsersRequest *request = [STGetSuggestUsersRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.offset = offset;
    request.followType = followType;
    [[STNetworkQueueManager sharedManager] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetSuggestUsersRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        NSString *url = [weakSelf urlString];
        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];
        params[@"offset"] = weakSelf.offset;
        params[@"limit"] = @(25);

        [[STNetworkManager sharedManager] POST:url
                                    parameters:params
                                       success:weakSelf.standardSuccessBlock
                                       failure:weakSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return (_followType == STFollowTypePeople)?kGetPeopleYouShouldFollow:kGetFriendsYouShouldFollow;
}
@end

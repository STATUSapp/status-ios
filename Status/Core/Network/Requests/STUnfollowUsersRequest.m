//
//  STUnfollowUsersRequest.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 31/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STUnfollowUsersRequest.h"

@implementation STUnfollowUsersRequest
+ (void)unfollowUsers:(NSArray *)users
     withCompletion:(STRequestCompletionBlock)completion
            failure:(STRequestFailureBlock)failure{
    
    STUnfollowUsersRequest *request = [STUnfollowUsersRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.users = users;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STUnfollowUsersRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        NSString *url = [weakSelf urlString];
        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];
        params[@"ids"] = [[weakSelf.users valueForKey:@"uuid"] componentsJoinedByString:@","];
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
    return kUnfollowUsers;
}
@end

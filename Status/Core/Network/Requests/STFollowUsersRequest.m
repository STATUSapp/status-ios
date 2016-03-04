//
//  STFollowUsersRequest.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 31/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STFollowUsersRequest.h"

@implementation STFollowUsersRequest
+ (void)followUsers:(NSArray *)users
     withCompletion:(STRequestCompletionBlock)completion
            failure:(STRequestFailureBlock)failure{
    
    STFollowUsersRequest *request = [STFollowUsersRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.users = users;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STFollowUsersRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        NSString *url = [weakSelf urlString];
        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];
        params[@"ids"] = [[weakSelf.users valueForKey:@"uuid"] componentsJoinedByString:@","];
        
        [[STNetworkQueueManager networkAPI] POST:url
                                    parameters:params
                                       success:weakSelf.standardSuccessBlock
                                       failure:weakSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kFollowUsers;
}
@end

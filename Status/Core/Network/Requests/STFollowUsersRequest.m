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
        
        __strong STFollowUsersRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
        params[@"ids"] = [[strongSelf.users valueForKey:@"uuid"] componentsJoinedByString:@","];
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
    return kFollowUsers;
}
@end

//
//  STInviteFriendsByEmailRequest.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 27/09/15.
//  Copyright © 2015 Andrus Cosmin. All rights reserved.
//

#import "STInviteFriendsByEmailRequest.h"

@implementation STInviteFriendsByEmailRequest
+ (void)inviteFriends:(NSArray *)friends
       withCompletion:(STRequestCompletionBlock)completion
              failure:(STRequestFailureBlock)failure{
    
    STInviteFriendsByEmailRequest *request = [STInviteFriendsByEmailRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.friends = friends;
    [[STNetworkQueueManager sharedManager] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STInviteFriendsByEmailRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        NSString *url = [weakSelf urlString];
        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];
        params[@"friends"] = weakSelf.friends;
        [[STNetworkManager sharedManager] POST:url
                                   parameters:params
                                      success:weakSelf.standardSuccessBlock
                                      failure:weakSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kInviteFriendsByEmail;
}
@end

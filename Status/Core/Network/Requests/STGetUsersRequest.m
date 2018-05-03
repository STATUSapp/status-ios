//
//  STGetUsersRequest.m
//  Status
//
//  Created by Cosmin Andrus on 30/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STGetUsersRequest.h"

@implementation STGetUsersRequest
+ (void)getUsersForScope:(STSearchScopeControl)scope
          withSearchText:(NSString *)searchText
               andOffset:(NSInteger)offset
              completion:(STRequestCompletionBlock)completion
                 failure:(STRequestFailureBlock)failure{
    
    STGetUsersRequest *request = [STGetUsersRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.scope = scope;
    request.searchText = searchText;
    request.offset = offset;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetUsersRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        __strong STGetUsersRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSInteger limit = 20;
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
        params[@"limit"] = @(limit);
        params[@"offset"] = @(strongSelf.offset);
        if (strongSelf.searchText && strongSelf.searchText.length) {
            params[@"search"] = strongSelf.searchText;
        }
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
    NSString *apiCall = @"";
    switch (_scope) {
        case STSearchControlAll:
            apiCall = kGetAllUsers;
            break;
        case STSearchControlNearby:
            apiCall = kGetNearby;
            break;
        case STSearchControlRecent:
            apiCall = kGetRecent;
            break;            
    }
    return apiCall;
}
@end

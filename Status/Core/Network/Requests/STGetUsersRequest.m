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
        NSString *url = [self urlString];
        NSInteger limit = 100;
        NSMutableDictionary *params = [self getDictParamsWithToken];
        params[@"limit"] = @(limit);
        params[@"offset"] = @(weakSelf.offset);
        if (weakSelf.searchText && weakSelf.searchText.length) {
            params[@"search"] = weakSelf.searchText;
        }
        [[STNetworkQueueManager networkAPI] GET:url
                                    parameters:params
                                       success:weakSelf.standardSuccessBlock
                                       failure:weakSelf.standardErrorBlock];
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
            
        default:
            apiCall = STSearchControlAll;
            break;
    }
    return apiCall;
}
@end

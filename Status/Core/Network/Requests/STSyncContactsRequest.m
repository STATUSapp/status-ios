//
//  STSyncContactsRequest.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 07/10/15.
//  Copyright © 2015 Andrus Cosmin. All rights reserved.
//

#import "STSyncContactsRequest.h"

@implementation STSyncContactsRequest
+ (void)syncLocalContacts:(NSArray *)localContacts
       andfacebookFriends:(NSArray *)facebookFriends
       withCompletion:(STRequestCompletionBlock)completion
              failure:(STRequestFailureBlock)failure{
    
    STSyncContactsRequest *request = [STSyncContactsRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.localContacts = localContacts;
    request.facebookFriends = facebookFriends;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STSyncContactsRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        NSString *url = [weakSelf urlString];
        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];
        NSMutableDictionary *contactsDict = [NSMutableDictionary new];
        if (weakSelf.localContacts) {
            contactsDict[@"emails"] = weakSelf.localContacts;
        }
        else
            contactsDict[@"emails"] = @[];
        if (weakSelf.facebookFriends) {
            contactsDict[@"facebookFriends"] = weakSelf.facebookFriends;
        }
        else
            contactsDict[@"facebookFriends"] = @[];
        params[@"contacts"] = contactsDict;
        [[STNetworkQueueManager networkAPI] POST:url
                                    parameters:params
                                        progress:nil
                                       success:weakSelf.standardSuccessBlock
                                       failure:weakSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kSyncContacts;
}

@end

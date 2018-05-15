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
        
        __strong STSyncContactsRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
        NSMutableDictionary *contactsDict = [NSMutableDictionary new];
        if (strongSelf.localContacts) {
            contactsDict[@"emails"] = strongSelf.localContacts;
        }
        else
            contactsDict[@"emails"] = @[];
        if (strongSelf.facebookFriends) {
            contactsDict[@"facebookFriends"] = strongSelf.facebookFriends;
        }
        else
            contactsDict[@"facebookFriends"] = @[];
        params[@"contacts"] = contactsDict;
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
    return kSyncContacts;
}

@end

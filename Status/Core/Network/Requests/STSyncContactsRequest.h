//
//  STSyncContactsRequest.h
//  Status
//
//  Created by Cosmin Adelin Andrus on 07/10/15.
//  Copyright © 2015 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STSyncContactsRequest : STBaseRequest
@property (nonatomic, strong) NSArray *localContacts;
@property (nonatomic, strong) NSArray *facebookFriends;
+ (void)syncLocalContacts:(NSArray *)localContacts
       andfacebookFriends:(NSArray *)facebookFriends
           withCompletion:(STRequestCompletionBlock)completion
                  failure:(STRequestFailureBlock)failure;
@end

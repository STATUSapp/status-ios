//
//  STUnfollowUsersRequest.h
//  Status
//
//  Created by Cosmin Adelin Andrus on 31/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STUnfollowUsersRequest : STBaseRequest
@property(nonatomic, strong)NSArray *users;
+ (void)unfollowUsers:(NSArray *)users
       withCompletion:(STRequestCompletionBlock)completion
              failure:(STRequestFailureBlock)failure;
@end

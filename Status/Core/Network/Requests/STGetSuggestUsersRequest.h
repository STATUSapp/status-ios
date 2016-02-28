//
//  STGetSuggestUsers.h
//  Status
//
//  Created by Cosmin Adelin Andrus on 17/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"
typedef NS_ENUM(NSInteger, STFollowType) {
    STFollowTypePeople = 0,
    STFollowTypeFriends,
    STFollowTypeFriendsAndPeople
};

@interface STGetSuggestUsersRequest : STBaseRequest
@property (nonatomic, strong) NSNumber *offset;
@property (nonatomic) STFollowType followType;
+ (void)getSuggestUsersForFollowType:(STFollowType)followType
                          withOffset:(NSNumber *)offset
                      withCompletion:(STRequestCompletionBlock)completion
                             failure:(STRequestFailureBlock)failure;

@end

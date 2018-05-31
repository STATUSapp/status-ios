//
//  STUsersPool.h
//  Status
//
//  Created by Andrus Cosmin on 14/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STBasePool.h"

@class STSuggestedUser;

@interface STUsersPool : STBasePool

- (void)addUsers:(NSArray <STSuggestedUser * > *)users;
- (STSuggestedUser *)getUserWithId:(NSString *)userId;
- (NSArray *)getUsersForIds:(NSArray<NSString *> *)idArray;
- (NSArray <STSuggestedUser *> *)getAllUsers;
- (void)clearAllUsers;
- (void)removeUsers:(NSArray <STSuggestedUser * > *)users;
- (void)removeUsersWithIDs:(NSArray <NSString * > *)uuids;
@end

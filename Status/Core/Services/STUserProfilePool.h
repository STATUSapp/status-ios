//
//  STUserProfilePool.h
//  Status
//
//  Created by Andrus Cosmin on 30/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STBasePool.h"
@class STUserProfile;
@interface STUserProfilePool : STBasePool

- (void)addProfiles:(NSArray <STUserProfile * > *)users;
- (STUserProfile *)getUserProfileWithId:(NSString *)userId;
- (NSArray <STUserProfile *> *)getAllProfiles;
- (void)clearAllProfiles;
- (void)removeProfiles:(NSArray <STUserProfile * > *)users;
- (void)removeProfilesWithIDs:(NSArray <NSString * > *)uuids;

@end

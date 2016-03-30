//
//  STUserProfilePool.m
//  Status
//
//  Created by Andrus Cosmin on 30/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STUserProfilePool.h"
#import "STUserProfile.h"

@implementation STUserProfilePool
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - Public methods

- (void)addProfiles:(NSArray <STUserProfile * > *)users{
    [super addObjects:users];
}

- (STUserProfile *)getUserProfileWithId:(NSString *)userId{
    return (STUserProfile *)[super getObjectWithId:userId];
}

- (NSArray <STUserProfile *> *)getAllProfiles{
    return (NSArray<STUserProfile *> *)[super getAllObjects];
}

- (void)clearAllProfiles{
    [super clearAllObjects];
}

- (void)removeProfiles:(NSArray <STUserProfile * > *)users{
    [super removeObjects:users];
}

- (void)removeProfilesWithIDs:(NSArray <NSString * > *)uuids{
    [super removeObjectsWithIDs:uuids];
}

@end

//
//  STUsersPool.m
//  Status
//
//  Created by Andrus Cosmin on 14/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STUsersPool.h"
#import "STSuggestedUser.h"

@implementation STUsersPool

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - Public methods

- (void)addUsers:(NSArray <STSuggestedUser * > *)users{
    [super addObjects:users];
}

- (STSuggestedUser *)getUserWithId:(NSString *)userId{
    return (STSuggestedUser *)[super getObjectWithId:userId];
}

- (NSArray *)getUsersForIds:(NSArray<NSString *> *)idArray{
    return [super getObjecstWithIds:idArray];
}
- (NSArray <STSuggestedUser *> *)getAllUsers{
    return (NSArray<STSuggestedUser *> *)[super getAllObjects];
}

- (void)clearAllUsers{
    [super clearAllObjects];
}

- (void)removeUsers:(NSArray <STSuggestedUser * > *)users{
    [super removeObjects:users];
}

- (void)removeUsersWithIDs:(NSArray <NSString * > *)uuids{
    [super removeObjectsWithIDs:uuids];
}

@end

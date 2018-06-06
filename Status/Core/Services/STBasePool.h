//
//  STBasePool.h
//  Status
//
//  Created by Andrus Cosmin on 14/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, STPoolType) {
    STPoolTypeNotDefined = 0,
    STPoolTypePosts,
    STPoolTypeUsers,
    STPoolTypeProfiles
};
@class STBaseObj;

@interface STBasePool : NSObject

- (void)addObjects:(NSArray <STBaseObj * > *)objects;
- (STBaseObj *)getObjectWithId:(NSString *)objectsId;
- (NSArray <STBaseObj *> *)getObjecstWithIds:(NSArray <NSString *> *)objectsIds;
- (NSArray <STBaseObj *> *)getAllObjects;
- (void)clearAllObjects;
- (void)removeObjects:(NSArray <STBaseObj * > *)objects;
- (void)removeObjectsWithIDs:(NSArray <NSString * > *)uuids;

//hook methods
-(STPoolType)poolType;
@end

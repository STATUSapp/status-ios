//
//  STUsersPool.m
//  Status
//
//  Created by Andrus Cosmin on 14/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STBasePool.h"
#import "STBaseObj.h"
#import "STPost.h"
#import "STUserProfile.h"
#import "STSuggestedUser.h"

#import "STLocalNotificationService.h"

@interface STBasePool ()

@property (nonatomic, strong) NSMutableDictionary <NSString *, STBaseObj *> * objects;

@end

@implementation STBasePool

- (instancetype)init {
    self = [super init];
    if (self) {
        _objects = [@{} mutableCopy];
    }
    return self;
}

#pragma mark - Public methods

- (void)addObjects:(NSArray <STBasePool * > *)objects{
    for (STBaseObj * obj in objects) {
        [self addOrUpdateObject:obj];
    }

}
- (STBaseObj *)getObjectWithId:(NSString *)objectsId{
    return [_objects valueForKey:objectsId];

}

- (NSArray <STBaseObj *> *)getObjecstWithIds:(NSArray <NSString *> *)objectsIds{
    NSMutableArray <STBaseObj *> *result = [@[] mutableCopy];
    for (NSString *uuid in objectsIds) {
        STBaseObj *obj = [self getObjectWithId:uuid];
        if (obj) {
            [result addObject:obj];
        }
    }
    return result;
}

- (NSArray <STBaseObj *> *)getAllObjects{
    return [_objects allValues];
}
- (void)clearAllObjects{
    [_objects removeAllObjects];
}
- (void)removeObjects:(NSArray <STBaseObj * > *)objects{
    NSMutableArray * objectsIDs = [NSMutableArray array];
    for (STBaseObj * obj in objects) {
        [objectsIDs addObject:obj.uuid];
    }
    
    [self removeObjectsWithIDs:objectsIDs];
}
- (void)removeObjectsWithIDs:(NSArray <NSString * > *)uuids{
    NSSet *removedObjects = [NSSet setWithArray:[self getObjecstWithIds:uuids]];
    [_objects removeObjectsForKeys:uuids];
    for (id object in removedObjects) {
        if ([object isKindOfClass:[STPost class]]) {
            [[CoreManager localNotificationService] postNotificationName:STPostPoolObjectDeletedNotification object:nil userInfo:@{kPostIdKey:((STPost *)object).uuid}];
        }
        else if ([object isKindOfClass:[STUserProfile class]]){
            [[CoreManager localNotificationService] postNotificationName:STProfilePoolObjectDeletedNotification object:nil userInfo:@{kUserIdKey:((STPost *)object).uuid}];
        }
        //here is where we should add anoter notifications
    }
}

- (STBaseObj *)randomObject {
    return [NSSet setWithArray:[_objects allValues]].anyObject;
}

- (STBaseObj *)objectForUrl:(NSString *)url{
    NSArray *filteredArray = [[self getAllObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"mainImageUrl like %@", url]];
    STBaseObj *result = [filteredArray firstObject];    
    return result;
}


#pragma mark - Private methods

- (void)addOrUpdateObject:(STBaseObj *)obj {
    NSInteger countBeforeInsert = _objects.allKeys.count;
    [_objects setValue:obj forKey:obj.uuid];
    NSInteger countAfterInsert = _objects.count;

    if (countAfterInsert > 0) {
        
        if (countBeforeInsert<countAfterInsert) {
            //new object added
            //here is where we should add more notifications
            if ([obj isKindOfClass:[STPost class]]) {
                NSString *userId = ((STPost *)obj).userId;
                if (userId) {
                    [[CoreManager localNotificationService] postNotificationName:STPostPoolNewObjectNotification object:nil userInfo:@{kUserIdKey:userId, kPostIdKey:obj.uuid}];
                }
            }
            else if ([obj isKindOfClass:[STUserProfile class]]) {
                [[CoreManager localNotificationService] postNotificationName:STProfilePoolNewObjectNotification object:nil userInfo:@{kUserIdKey:obj.uuid}];
            }
        }
        else if (countBeforeInsert == countAfterInsert){
            //there was an update
            //here is where we should add more notifications
            if ([obj isKindOfClass:[STPost class]]) {
                [[CoreManager localNotificationService] postNotificationName:STPostPoolObjectUpdatedNotification object:nil userInfo:@{kPostIdKey:obj.uuid}];
                [(STPost *)obj resetCaptionAndHashtags];
            }
            else if ([obj isKindOfClass:[STUserProfile class]]){
                [[CoreManager localNotificationService] postNotificationName:STProfilePoolObjectUpdatedNotification object:nil userInfo:@{kUserIdKey:obj.uuid}];
            }else if ([obj isKindOfClass:[STSuggestedUser class]]){
                [[CoreManager localNotificationService] postNotificationName:STUserPoolObjectUpdatedNotification object:nil userInfo:@{kUserIdKey:obj.uuid}];
            }
        }
    }
}

#pragma mark - Notifications
-(STPoolType)poolType{
    NSAssert(NO, @"poolType not implemented");
    return STPoolTypeNotDefined;
}
@end

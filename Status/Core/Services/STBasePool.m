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
#import "STLocalNotificationService.h"

@interface STBasePool ()

@property (nonatomic, strong) NSMutableSet <STBaseObj *> * objects;

@end

@implementation STBasePool

- (instancetype)init {
    self = [super init];
    if (self) {
        _objects = [NSMutableSet set];
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
    NSPredicate * predicate = [NSPredicate predicateWithBlock:^BOOL(STBaseObj *  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject.uuid isEqualToString:objectsId];
    }];
    return [_objects filteredSetUsingPredicate:predicate].anyObject;

}
- (NSArray <STBaseObj *> *)getAllObjects{
    return _objects.allObjects;
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
    NSPredicate * removePredicate = [NSPredicate predicateWithBlock:^BOOL(STBaseObj *  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return ![uuids containsObject:evaluatedObject.uuid];
    }];
    NSSet *matches = [_objects filteredSetUsingPredicate:removePredicate];
    for (id object in matches) {
        if ([object isKindOfClass:[STPost class]]) {
            [[CoreManager notificationService] postNotificationName:STPostPoolObjectDeletedNotification object:nil userInfo:@{kPostIdKey:((STPost *)object).uuid}];
        }
        //TODO: dev_1_2 add anoter notifications
    }
    [_objects filterUsingPredicate:removePredicate];

}


#pragma mark - Private methods

- (void)addOrUpdateObject:(STBaseObj *)obj {
    NSPredicate * removePreviousInstancesOfPostPredicate = [NSPredicate predicateWithBlock:^BOOL(STBaseObj *  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return ![evaluatedObject.uuid isEqualToString:obj.uuid];
    }];
    NSInteger countBeforeFilter = _objects.count;
    [_objects filterUsingPredicate:removePreviousInstancesOfPostPredicate];
    NSInteger countAfterFilter = _objects.count;
    [_objects addObject:obj];

    if (countBeforeFilter > 0 && countBeforeFilter>countAfterFilter) {
        //there was an update
        if ([obj isKindOfClass:[STPost class]]) {
            [[CoreManager notificationService] postNotificationName:STPostPoolObjectUpdatedNotification object:nil userInfo:@{kPostIdKey:obj.uuid}];
        }
        //TODO: dev_1_2 add more updates here
    }
}


@end

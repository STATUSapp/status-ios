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

#import "STLocalNotificationService.h"

@interface STBasePool ()

@property (nonatomic, strong) NSMutableSet <STBaseObj *> * objects;

@end

@implementation STBasePool

- (instancetype)init {
    self = [super init];
    if (self) {
        _objects = [NSMutableSet set];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageWasSavedLocally:) name:STLoadImageNotification object:nil];
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
        return [uuids containsObject:evaluatedObject.uuid];
    }];
    NSMutableSet *matches =[NSMutableSet setWithSet:_objects];
    NSSet *removedObjects = [_objects filteredSetUsingPredicate:removePredicate];
    [matches minusSet:removedObjects];
    _objects = matches;
    for (id object in matches) {
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
    NSSet *downloadedSet = [self.objects filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"mainImageDownloaded == YES"]];
    if (downloadedSet.count == 0) {
        return nil;
    }
    
    return downloadedSet.anyObject;
}

- (STBaseObj *)objectForUrl:(NSString *)url{
    NSArray *filteredArray = [[self getAllObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"mainImageUrl like %@", url]];
    STBaseObj *result = [filteredArray firstObject];    
    return result;
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

    if (countBeforeFilter > 0) {
        
        if (countBeforeFilter>countAfterFilter) {
            //there was an update
            //here is where we should add more notifications
            if ([obj isKindOfClass:[STPost class]]) {
                [[CoreManager localNotificationService] postNotificationName:STPostPoolObjectUpdatedNotification object:nil userInfo:@{kPostIdKey:obj.uuid}];
            }
            else if ([obj isKindOfClass:[STUserProfile class]]){
                [[CoreManager localNotificationService] postNotificationName:STProfilePoolObjectUpdatedNotification object:nil userInfo:@{kUserIdKey:obj.uuid}];
            }
        }
        
        else if (countBeforeFilter == countAfterFilter){
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
    }
}

#pragma mark - Notifications

-(void)imageWasSavedLocally:(NSNotification *)notif{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *fullUrl = notif.userInfo[kImageUrlKey];
        CGSize imageSize = CGSizeFromString(notif.userInfo[kImageSizeKey]);
        STBaseObj *updatedObj = [self objectForUrl:fullUrl];
        if (updatedObj) {
            updatedObj.mainImageDownloaded = YES;
            updatedObj.imageSize = imageSize;
            [[CoreManager localNotificationService] postNotificationName:STPostPoolObjectUpdatedNotification object:nil userInfo:@{kPostIdKey:updatedObj.uuid}];
        }
    });
}


@end

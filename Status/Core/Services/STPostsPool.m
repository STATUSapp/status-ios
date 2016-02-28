//
//  STPostsPool.m
//  Status
//
//  Created by Silviu Burlacu on 28/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STPostsPool.h"
#import "STPost.h"

@interface STPostsPool ()

@property (nonatomic, strong) NSMutableSet <STPost *> * posts;

@end

@implementation STPostsPool

- (instancetype)init {
    self = [super init];
    if (self) {
        _posts = [NSMutableSet set];
    }
    return self;
}


#pragma mark - Public methods

- (void)addPosts:(NSArray<STPost *> *)posts {
    for (STPost * post in posts) {
        [self addOrUpdatePost:post];
    }
}

- (NSArray<STPost *> *)getAllPosts {
    return _posts.allObjects;
}

- (void)clearAllPosts {
    [_posts removeAllObjects];
}

- (void)removePosts:(NSArray<STPost *> *)posts {
    NSMutableArray * postsIDs = [NSMutableArray array];
    for (STPost * post in posts) {
        [postsIDs addObject:post.uuid];
    }
    
    NSPredicate * removePredicate = [NSPredicate predicateWithBlock:^BOOL(STPost *  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return ![postsIDs containsObject:evaluatedObject.uuid];
    }];
    [_posts filterUsingPredicate:removePredicate];
}

- (STPost *)getPostWithId:(NSString *)postId {
    NSPredicate * predicate = [NSPredicate predicateWithBlock:^BOOL(STPost *  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject.uuid isEqualToString:postId];
    }];
    return [_posts filteredSetUsingPredicate:predicate].anyObject;
}

#pragma mark - Private methods

- (void)addOrUpdatePost:(STPost *)post {
    NSPredicate * removePreviousInstancesOfPostPredicate = [NSPredicate predicateWithBlock:^BOOL(STPost *  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return ![evaluatedObject.uuid isEqualToString:post.uuid];
    }];
    [_posts filterUsingPredicate:removePreviousInstancesOfPostPredicate];
    [_posts addObject:post];
}

@end

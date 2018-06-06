//
//  STPostsPool.m
//  Status
//
//  Created by Silviu Burlacu on 28/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STPostsPool.h"
#import "STPost.h"
#import "STUserProfile.h"
#import "STLocalNotificationService.h"

@interface STPostsPool ()

@end

@implementation STPostsPool

- (instancetype)init {
    self = [super init];
    if (self) {

    }
    return self;
}

#pragma mark - Public methods

- (void)addPosts:(NSArray<STPost *> *)posts {
    [super addObjects:posts];
}

- (NSArray<STPost *> *)getAllPosts {
    return (NSArray<STPost *> *)[super getAllObjects];
}

- (void)clearAllPosts {
    [super clearAllObjects];
}

- (void)removePosts:(NSArray<STPost *> *)posts {
    [super removeObjects:posts];
}

- (void)removePostsWithIDs:(NSArray<NSString *> *)uuids {
    [super removeObjectsWithIDs:uuids];
}

- (STPost *)getPostWithId:(NSString *)postId {
    return (STPost *)[super getObjectWithId:postId];
}

-(STPoolType)poolType{
    return STPoolTypePosts;
}


- (STPost *)randomPost {

    NSArray *allObjects = [[self getAllObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"mainImageDownloaded == YES AND mainImageUrl != nil"]];
    if (allObjects.count == 0) {
        return nil;
    }
    
    STPost * randomPost = nil;
    
    while (randomPost.mainImageUrl == nil) {
        u_int32_t randomIndex = arc4random_uniform((u_int32_t)(allObjects.count - 1));
        randomPost = [allObjects objectAtIndex:randomIndex];
    }
    return randomPost;
}

#pragma mark - Private methods

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

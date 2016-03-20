//
//  STPostsPool.m
//  Status
//
//  Created by Silviu Burlacu on 28/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STPostsPool.h"
#import "STPost.h"
#import "STLocalNotificationService.h"

@interface STPostsPool ()

@end

@implementation STPostsPool

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageWasSavedLocally:) name:STLoadImageNotification object:nil];

    }
    return self;
}

#pragma mark - Notifications

-(void)imageWasSavedLocally:(NSNotification *)notif{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *fullUrl = notif.userInfo[kImageUrlKey];
        STPost *updatedPost = [self postForUrl:fullUrl];
        if (updatedPost) {
            updatedPost.imageDownloaded = YES;
            [[CoreManager localNotificationService] postNotificationName:STPostPoolObjectUpdatedNotification object:nil userInfo:@{kPostIdKey:updatedPost.uuid}];
        }
    });
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

- (STPost *)randomPost {
    if (self.getAllPosts.count == 0) {
        return nil;
    }
    
    STPost * randomPost = nil;
    
    while (randomPost.fullPhotoUrl == nil) {
        u_int32_t randomIndex = arc4random_uniform((u_int32_t)(self.getAllPosts.count - 1));
        randomPost = [self.getAllPosts objectAtIndex:randomIndex];
    }
    return randomPost;
}

#pragma mark - Private methods

- (STPost *)postForUrl:(NSString *)url{
    NSArray *filteredArray = [[self getAllPosts] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"fullPhotoUrl like %@", url]];
    return [filteredArray firstObject];
}

@end

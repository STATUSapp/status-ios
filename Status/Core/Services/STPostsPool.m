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
        NSString *fullUrl = (NSString *)notif.object;
        STPost *updatedPost = [self postForUrl:fullUrl];
        if (updatedPost) {
            updatedPost.imageDownloaded = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:STPostPoolObjectUpdatedNotification object:updatedPost];
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

#pragma mark - Private methods

- (STPost *)postForUrl:(NSString *)url{
    NSArray *filteredArray = [[self getAllPosts] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"fullPhotoUrl like %@", url]];
    return [filteredArray firstObject];
}

@end

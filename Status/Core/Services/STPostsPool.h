//
//  STPostsPool.h
//  Status
//
//  Created by Silviu Burlacu on 28/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STBasePool.h"
#import "STPost.h"

@interface STPostsPool : STBasePool

- (void)addPosts:(NSArray <STPost * > *)posts;
- (STPost *)getPostWithId:(NSString *)postId;
- (NSArray <STPost *> *)getAllPosts;
- (void)clearAllPosts;
- (void)removePosts:(NSArray <STPost * > *)posts;
- (void)removePostsWithIDs:(NSArray <NSString * > *)uuids;
- (STPost *)randomPost;
- (NSArray <STPost *> *)randomPostsForAllTops;

@end

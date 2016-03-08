//
//  STPostFlowProcessor.m
//  Status
//
//  Created by Cosmin Home on 28/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STPostFlowProcessor.h"
#import "STDataAccessUtils.h"
#import "STLocationManager.h"
#import "STPost.h"
#import "CoreManager.h"
#import "STPostsPool.h"

NSString * const kNotificationPostDownloadFailed = @"NotificationPostDownloadFailed";
NSString * const kNotificationPostDownloadSuccess = @"NotificationPostDownloadSuccess";

@interface STPostFlowProcessor ()

@property (nonatomic) STFlowType flowType;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *postId;

@property (nonatomic, strong) NSMutableArray *postIds;
@property (nonatomic) NSInteger numberOfDuplicates;
@property (nonatomic, assign) BOOL loaded;

@end

@implementation STPostFlowProcessor

-(instancetype)initWithFlowType:(STFlowType)flowType{
    self = [super init];
    if (self) {
        self.flowType = flowType;
        self.postIds = [NSMutableArray new];
        if (flowType == STFlowTypeHome ||
            flowType == STFlowTypePopular||
            flowType == STFlowTypeRecent) {
            [self getMoreData];
        }
    }
    return self;
}

-(instancetype)initWithFlowType:(STFlowType)flowType
                         userId:(NSString *)userId{
    self = [self initWithFlowType:flowType];
    if (self) {
        self.userId = userId;
        [self getMoreData];
    }
    return self;
}

-(instancetype)initWithFlowType:(STFlowType)flowType
                         postId:(NSString *)postId{
    self = [self initWithFlowType:flowType];
    if (self) {
        self.postId = postId;
        [self getMoreData];
    }
    return self;
}

#pragma makr - Interface Methods

-(NSInteger)numberOfPosts{
    return _postIds.count;
}

-(STPost *)postAtIndex:(NSInteger)index{
    NSString *postId = [_postIds objectAtIndex:index];
    STPost *postForId = [[CoreManager postsPool] getPostWithId:postId];
    return postForId;
}

- (void)processPostAtIndex:(NSInteger)index {
    if (index >= _postIds.count)
        return;
    
    if (_flowType == STFlowTypeSinglePost)
        return;
    
    __block STPost *post = [self postAtIndex:index];
    __weak STPostFlowProcessor *weakSelf = self;
    
        NSInteger offsetRemaining = weakSelf.postIds.count - index;
        BOOL shouldGetNextBatch = (offsetRemaining == kStartLoadOffset) && index!=0;
        if (shouldGetNextBatch) {
            [weakSelf getMoreData];
        }
    
    if (self.flowType == STFlowTypePopular ||
        self.flowType == STFlowTypeRecent ||
        self.flowType == STFlowTypeHome) {

        if (post.postSeen == TRUE) {
            return;
        }
        
        [STDataAccessUtils setPostSeenForPostId:post.uuid
                                 withCompletion:^(NSError *error) {
                                     if (error==nil) {
                                         STPost *post = [self postAtIndex:index];
                                         post.postSeen = YES;
                                     }
                                     else
                                     {
                                         //TODO: dev_1_2 retry later?
                                     }
                                 }];
    }
}

-(void)deleteItemAtIndex:(NSInteger)index
{
    [_postIds removeObjectAtIndex:index];
}


#pragma mark - Internal Helpers

-(void)updatePostIdsWithNewArray:(NSArray *)array{
    
    NSMutableArray *sheetArray = [NSMutableArray arrayWithArray:array];
    
    
    STPost *firstPost = [[CoreManager postsPool] getPostWithId:[_postIds firstObject]];
    if (array.count > 0 &&
        firstPost &&
        [firstPost isLoadingPost]) {
        [_postIds removeObject:firstPost.uuid];
    }
    
    for (NSString *postId in array) {
        if ([_postIds containsObject:postId]) {
            NSLog(@"Duplicate found");
            [sheetArray removeObject:postId];
            _numberOfDuplicates++;
        }
    }
    
    [_postIds addObjectsFromArray:sheetArray];
}


-(void)getMoreData{
    if (_postIds.count == 0) {//add mock loading post
        STPost *loadingPost = [STPost mockPostLoading];
        [_postIds addObject:loadingPost.uuid];
        [[CoreManager postsPool] addPosts:@[loadingPost]];
        
    }
    NSInteger offset = _postIds.count + _numberOfDuplicates;
    NSLog(@"Offset: %ld", (long)offset);

    __weak STPostFlowProcessor *weakSelf = self;
    STDataAccessCompletionBlock completion = ^(NSArray *objects, NSError *error){
        if (error) {
            if (_flowType == STFlowTypeDiscoverNearby &&
                [error.domain isEqualToString:@"LOCATION_MISSING_ERROR"] &&
                error.code == 404) {
                //user has no location force an update
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newLocationHasBeenUploaded) name:kNotificationNewLocationHasBeenUploaded object:nil];
                [[CoreManager locationService] forceLocationToUpdate];
            }
            else
            {
                weakSelf.loaded = YES;
                //handle error
                //TODO: dev_1_2 handle the listener
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPostDownloadFailed
                                                                    object:nil];
                
                //TODO: dev_1_2 enable refresh button
                
            }

        }
        else
        {
            weakSelf.loaded = YES;
            //TODO: dev_1_2 handle the listener
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPostDownloadSuccess
                                                                object:nil];
            
            [weakSelf updatePostIdsWithNewArray:[objects valueForKey:@"uuid"]];
            
            //TODO: dev_1_2 show Suggestions
            //TODO: dev_1_2 start load images
            //TODO: dev_1_2 enable refresh button
        }
    };
    switch (_flowType) {
        case STFlowTypePopular:
        case STFlowTypeHome:
        case STFlowTypeRecent:
        {
            
            [STDataAccessUtils getPostsForFlow:_flowType
                                        offset:offset
                                withCompletion:completion];
            break;
        }
        case STFlowTypeDiscoverNearby: {
            
            [STDataAccessUtils getNearbyPostsWithOffset:offset
                                         withCompletion:completion];
            
            break;
        }
        case STFlowTypeMyGallery:
        case STFlowTypeUserGallery:{
            
            [STDataAccessUtils getPostsForUserId:_userId
                                          offset:offset
                                  withCompletion:completion];
            break;
        }
        case STFlowTypeSinglePost:{
            [STDataAccessUtils getPostWithPostId:_postId
                                          offset:offset
                                  withCompletion:completion];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Notifications

-(void)newLocationHasBeenUploaded{
    [self getMoreData];
}

@end

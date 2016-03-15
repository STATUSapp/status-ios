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

#import "STImageCacheController.h"

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
        _loaded = NO;
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
#ifdef DEBUG
        shouldGetNextBatch = NO;
#endif
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

- (void)deleteItemAtIndex:(NSInteger)index
{
    [_postIds removeObjectAtIndex:index];
}

- (BOOL)loading{
    return (_loaded == NO);
}

#pragma mark - Actions

- (void)setLikeUnlikeAtIndex:(NSInteger)index
              withCompletion:(STProcessorCompletionBlock)completion{
    NSString *postId = [_postIds objectAtIndex:index];
    [STDataAccessUtils setPostLikeUnlikeWithPostId:postId
                                    withCompletion:^(NSError *error) {
                                        completion(error);
                                    }];
}

#pragma mark - Internal Helpers

-(void)updatePostIdsWithNewArray:(NSArray *)array{
    
    NSMutableArray *sheetArray = [NSMutableArray arrayWithArray:array];
    
    for (NSString *postId in array) {
        if ([_postIds containsObject:postId]) {
            NSLog(@"Duplicate found");
            [sheetArray removeObject:postId];
            _numberOfDuplicates++;
        }
    }
    
    if (sheetArray.count > 0) {
        [_postIds addObjectsFromArray:sheetArray];
    }
    
    //remove loading mock post
    STPost *loadingPost = [[CoreManager postsPool] getPostWithId:kPostUuidForLoading];
    if (loadingPost) {
        [_postIds removeObject:loadingPost.uuid];
    }

    //add mock posts at the end of the list
    
    STPost *noPhotosPost = [[CoreManager postsPool] getPostWithId:kPostUuidForNoPhotosToDisplay];
    if (!noPhotosPost) {
        noPhotosPost = [STPost mockPostNoPhotosToDisplay];
        [[CoreManager postsPool] addPosts:@[noPhotosPost]];
    }
    else
        [_postIds removeObject:noPhotosPost.uuid];
    
    STPost *youSawAllPost = [[CoreManager postsPool] getPostWithId:kPostUuidForYouSawAll];
    if (!youSawAllPost) {
        youSawAllPost = [STPost mockPostYouSawAll];
        [[CoreManager postsPool] addPosts:@[youSawAllPost]];
    }
    else
        [_postIds removeObject:youSawAllPost.uuid];

    
    if (_postIds.count == 0 &&
        (_flowType == STFlowTypeMyGallery||
         _flowType == STFlowTypeUserGallery)) {
            [_postIds addObject:noPhotosPost.uuid];
        }
    else
        [_postIds addObject:youSawAllPost.uuid];

    
}


-(void)getMoreData{
    NSInteger offset = _postIds.count + _numberOfDuplicates;
    NSLog(@"Offset: %ld", (long)offset);
    
    if (_loaded == NO) {
        STPost *loadingPost = [STPost mockPostLoading];
        [[CoreManager postsPool] addPosts:@[loadingPost]];
        [self.postIds addObject:loadingPost.uuid];
    }

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
            
            [weakSelf updatePostIdsWithNewArray:[objects valueForKey:@"uuid"]];
            if (objects.count > 0) {
#ifdef DEBUG
                [objects setValue:@"Lorem ipsum dolor sit amet, eos cu prompta qualisque moderatius, eu utamur urbanitas his. Quod malorum eu qui, quo debet paulo soluta ad. Altera argumentum id mel. Ut tota soluta principes has, in alterum maiorum pro, mel graece pericula ut. Sea discere nominavi cu, id pro blandit complectitur. Ut per legere expetendis, te vel offendit intellegam." forKey:@"caption"];
#endif
                [[CoreManager postsPool] addPosts:objects];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPostDownloadSuccess
                                                                object:nil];
            [[CoreManager imageCacheService] startImageDownloadForNewFlowType:_flowType andDataSource:objects];

            
            //TODO: dev_1_2 show Suggestions
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

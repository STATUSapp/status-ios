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
#import "STFacebookHelper.h"
#import "STLocalNotificationService.h"
#import "STNavigationService.h"

#import "STImageCacheObj.h"

int const kDeletePostTag = 11;

NSString * const kNotificationPostDownloadFailed = @"NotificationPostDownloadFailed";
NSString * const kNotificationPostDownloadSuccess = @"NotificationPostDownloadSuccess";
NSString * const kNotificationPostUpdated = @"NotificationPostUpdated";
NSString * const kNotificationPostDeleted = @"NotificationPostDeleted";

@interface STPostFlowProcessor ()<UIAlertViewDelegate>
{
    NSString *postIdToDelete;
}

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
        
        [self registerForUpdates];
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

- (void)registerForUpdates{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShareOnFacebookNotification:) name:STOptionsViewShareFbNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSaveLocallyNotification:) name:STOptionsViewSaveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeletePostNotification:) name:STOptionsViewDeletePostNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReportPostNotification:) name:STOptionsViewReportPostNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postUpdated:) name:STPostPoolObjectUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postDeleted:) name:STPostPoolObjectDeletedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postImageWasEdited:) name:STPostImageWasEdited object:nil];



}

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

- (void)reloadProcessor{
    _loaded = NO;
    _numberOfDuplicates = 0;
    [_postIds removeAllObjects];
    [self getMoreData];
}

- (BOOL)canGoToUserProfile{
    if (_flowType == STFlowTypeUserGallery ||
        _flowType == STFlowTypeMyGallery) {
        return NO;
    }
    return YES;
}

- (BOOL)currentFlowUserIsTheLoggedInUser{
    return [_userId isEqualToString:[CoreManager loginService].currentUserUuid];
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

- (void)handleBigCameraButtonActionWithUserName:(NSString *)userName{
    switch (self.flowType) {
        case STFlowTypeMyGallery:{
            [[CoreManager navigationService] switchToTabBarAtIndex:STTabBarIndexTakAPhoto popToRootVC:YES];
            break;
        }
        case STFlowTypeUserGallery:{
            [STDataAccessUtils inviteUserToUpload:_userId withUserName:userName withCompletion:^(NSError *error) {
                if (!error) {
                    [[CoreManager navigationService] switchToTabBarAtIndex:STTabBarIndexHome popToRootVC:YES];
                }
            }];
            break;
        }
            
        default:
            return;
            break;
    }
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
                [[CoreManager notificationService] postNotificationName:kNotificationPostDownloadFailed
                                                                 object:self
                                                               userInfo:nil];
                
                //TODO: dev_1_2 enable refresh button
                
            }

        }
        else
        {
            weakSelf.loaded = YES;
            //TODO: dev_1_2 handle the listener
            
            if (objects.count > 0) {
//#ifdef DEBUG
//                [objects setValue:@"Lorem ipsum dolor sit amet, eos cu prompta qualisque moderatius, eu utamur urbanitas his. Quod malorum eu qui, quo debet paulo soluta ad. Altera argumentum id mel." forKey:@"caption"];
//#endif
            [weakSelf updatePostIdsWithNewArray:[objects valueForKey:@"uuid"]];

            [[CoreManager postsPool] addPosts:objects];
            }
            [[CoreManager notificationService] postNotificationName:kNotificationPostDownloadSuccess object:self userInfo:nil];
            NSMutableArray *objToDownload = [NSMutableArray new];
            for (STPost *post in objects) {
                STImageCacheObj *obj = [STImageCacheObj imageCacheObjFromPost:post];
                [objToDownload addObject:obj];
            }
            [[CoreManager imageCacheService] startImageDownloadForNewFlowType:_flowType andDataSource:objToDownload];

            
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

- (void)postImageWasEdited:(NSNotification *)notif{
    NSString *postId = notif.userInfo[kPostIdKey];
    if ([_postIds containsObject:postId]) {
        STPost *post = [[CoreManager postsPool] getPostWithId:postId];
        STImageCacheObj *objToDownload = [STImageCacheObj imageCacheObjFromPost:post];
        [[CoreManager imageCacheService] startImageDownloadForNewFlowType:_flowType andDataSource:@[objToDownload]];
    }

}

- (void)postUpdated:(NSNotification *)notif{
    NSString *postId = notif.userInfo[kPostIdKey];
    if ([_postIds containsObject:postId]) {
        [[CoreManager notificationService] postNotificationName:kNotificationPostUpdated object:self userInfo:@{kPostIdKey:postId}];
    }
}
- (void)postDeleted:(NSNotification *)notif{
    
    NSString *postId = notif.userInfo[kPostIdKey];
    if ([_postIds containsObject:postId]) {
        [[CoreManager notificationService] postNotificationName:kNotificationPostDeleted object:self userInfo:@{kPostIdKey:postId}];
    }
}



-(void)newLocationHasBeenUploaded{
    [self getMoreData];
}

//custom share view notifications
- (void)onShareOnFacebookNotification:(NSNotification*)notif{
    NSString *postId = notif.userInfo[kPostIdKey];
    STPost *post = [[CoreManager postsPool] getPostWithId:postId];
    [[CoreManager facebookService] shareImageWithImageUrl:post.fullPhotoUrl description:nil
                                            andCompletion:^(id result, NSError *error) {
        if(error==nil)
            [[[UIAlertView alloc] initWithTitle:@"Success"
                                        message:@"Your photo was posted."
                                       delegate:nil cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil] show];
        else
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:@"Something went wrong. You can try again later."
                                       delegate:nil cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil] show];
    }];
}

- (void)onSaveLocallyNotification:(NSNotification *)notif{
    NSString *postId = notif.userInfo[kPostIdKey];
    STPost *post = [[CoreManager postsPool] getPostWithId:postId];
    //TODO: dev_1_2 disable the button until the image is downloaded
    if (post.imageDownloaded) {
        __weak STPostFlowProcessor *weakSelf = self;
        [[CoreManager imageCacheService] loadPostImageWithName:post.fullPhotoUrl
                                            withPostCompletion:^(UIImage *origImg) {
                                                UIImageWriteToSavedPhotosAlbum(origImg, weakSelf, @selector(thisImage:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), NULL);
                                                
                                            } andBlurCompletion:nil];
    }

}

- (void)onDeletePostNotification:(NSNotification *)notif{
    postIdToDelete = notif.userInfo[kPostIdKey];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Post"
                                                        message:@"Are you sure you want to delete this post?"
                                                       delegate:self cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Delete", nil];
    [alertView setTag:kDeletePostTag];
    [alertView show];

}

- (void)onReportPostNotification:(NSNotification *)notif{
    NSString *postId = notif.userInfo[kPostIdKey];
    STPost *post = [[CoreManager postsPool] getPostWithId:postId];
    
    if ([post.reportStatus integerValue] == 1) {
            [STDataAccessUtils reportPostWithId:postId withCompletion:^(NSError *error) {
                NSLog(@"Post was reported with error: %@", nil);
            }];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Report Post" message:@"This post was already reported." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }

}

- (void)thisImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo {
    if (error)
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Something went wrong. You can try again later."
                                   delegate:nil cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
    else
        [[[UIAlertView alloc] initWithTitle:@"Success"
                                    message:@"Your photo was saved."
                                   delegate:nil cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kDeletePostTag) {
        if (buttonIndex==1) {
            
            [STDataAccessUtils deletePostWithId:postIdToDelete withCompletion:^(NSError *error) {
                postIdToDelete = nil;
                NSLog(@"Post deleted with error: %@", error);
            }];
        }
    }
}

@end

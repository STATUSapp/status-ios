//
//  STPostFlowProcessor.m
//  Status
//
//  Created by Cosmin Home on 28/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STFlowProcessor.h"
#import "STDataAccessUtils.h"
#import "STLocationManager.h"
#import "STPost.h"
#import "STUserProfile.h"
#import "CoreManager.h"
#import "STPostsPool.h"
#import "STUserProfilePool.h"
#import "STImageCacheController.h"
#import "STFacebookHelper.h"
#import "STLocalNotificationService.h"
#import "STNavigationService.h"

#import "STImageCacheObj.h"

int const kDeletePostTag = 11;

NSString * const kNotificationObjectDownloadFailed = @"NotificationDownloadFailed";
NSString * const kNotificationObjDownloadSuccess = @"NotificationDownloadSuccess";
NSString * const kNotificationObjUpdated = @"NotificationObjUpdated";
NSString * const kNotificationObjAdded = @"NotificationObjAdded";
NSString * const kNotificationObjDeleted = @"NotificationObjDeleted";
NSString * const kNotificationShowSuggestions = @"NotificationShowSuggestion";

NSString * const kShowSuggestionKey = @"SUGGESTIONS_SHOWED";

@interface STFlowProcessor ()<UIAlertViewDelegate>
{
    NSString *postIdToDelete;
}

@property (nonatomic) STFlowType flowType;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *postId;

@property (nonatomic, strong) STUserProfile *userProfile;
@property (nonatomic, strong) NSMutableArray *objectIds;
@property (nonatomic) NSInteger numberOfDuplicates;
@property (nonatomic, assign) BOOL loaded;
@property (nonatomic, assign) BOOL noMoreObjectsToDownload;

@property (nonatomic, assign) NSInteger offset;

@end

@implementation STFlowProcessor

-(instancetype)initWithFlowType:(STFlowType)flowType{
    self = [super init];
    if (self) {
        self.flowType = flowType;
        _loaded = NO;
        _objectIds = [NSMutableArray new];
        if (flowType == STFlowTypeHome ||
            flowType == STFlowTypePopular||
            flowType == STFlowTypeRecent ||
            flowType == STFlowTypeDiscoverNearby) {
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postUpdated:) name:STPostPoolObjectUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postDeleted:) name:STPostPoolObjectDeletedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postImageWasEdited:) name:STPostImageWasEdited object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postAdded:) name:STPostPoolNewObjectNotification object:nil];
}

-(NSInteger)numberOfObjects{
    return _objectIds.count;
}

- (id)objectAtIndex:(NSInteger)index{
    NSString *objId = [_objectIds objectAtIndex:index];
    if (_flowType == STFlowTypeDiscoverNearby) {
        STUserProfile *userProfileForId = [[CoreManager profilePool] getUserProfileWithId:objId];
        return userProfileForId;
    }
    else
    {
        STPost *postForId = [[CoreManager postsPool] getPostWithId:objId];
        return postForId;
    }
}

- (void)processObjectAtIndex:(NSInteger)index
           setSeenIfRequired:(BOOL)setSeenRequired{
    if (_noMoreObjectsToDownload == YES) {
        return;
    }
    
    if (index >= _objectIds.count)
        return;
    
    if (_flowType == STFlowTypeSinglePost)
        return;
    
    __block STPost *post = [self objectAtIndex:index];
    
//    __weak STFlowProcessor *weakSelf = self;
    
        NSInteger offsetRemaining = self.objectIds.count - index;
        BOOL shouldGetNextBatch = (offsetRemaining == kStartLoadOffset) && index!=0;
//    shouldGetNextBatch = NO;
    if (shouldGetNextBatch) {
            [self getMoreData];
        }
    if (!setSeenRequired) {
        return;
    }
    
    if (/*self.flowType == STFlowTypePopular ||
        self.flowType == STFlowTypeRecent ||*/
        self.flowType == STFlowTypeHome) {

        if (post.postSeen == TRUE) {
            return;
        }
        
        [STDataAccessUtils setPostSeenForPostId:post.uuid
                                 withCompletion:^(NSError *error) {
                                     if (error==nil) {
                                         STPost *post = [self objectAtIndex:index];
                                         post.postSeen = YES;
                                     }
                                 }];
    }
}

- (void)deleteObjectAtIndex:(NSInteger)index
{
    [_objectIds removeObjectAtIndex:index];
}

- (BOOL)loading{
    return (_loaded == NO);
}

- (void)reloadProcessor{
    _loaded = NO;
    _numberOfDuplicates = 0;
    _noMoreObjectsToDownload = NO;
    _offset = 0;
    [_objectIds removeAllObjects];
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

-(STFlowType)processorFlowType{
    return _flowType;
}

- (BOOL)processorIsAGallery{
    return (_flowType == STFlowTypeUserGallery ||
            _flowType == STFlowTypeMyGallery);
}

- (void)setCurrentOffset:(NSInteger)offset{
    _offset = offset;
}
- (NSInteger)currentOffset{
    return _offset;
}

- (NSInteger)indexOfObject:(id)object{
    return [_objectIds indexOfObject:[object valueForKey:@"uuid"]];
}

- (STUserProfile *)userProfile{
    STUserProfile *userProfile = _userProfile;
    if (userProfile == nil && _userId!=nil) {
        userProfile = [[CoreManager profilePool] getUserProfileWithId:_userId];

    }
    return userProfile;
}

- (NSString *)userId{
    return _userId;
}
#pragma mark - Actions

- (void)setLikeUnlikeAtIndex:(NSInteger)index
              withCompletion:(STProcessorCompletionBlock)completion{
    NSString *postId = [_objectIds objectAtIndex:index];
    [STDataAccessUtils setPostLikeUnlikeWithPostId:postId
                                    withCompletion:^(NSError *error) {
                                        completion(error);
                                    }];
}

- (void)handleBigCameraButtonActionWithUserName:(NSString *)userName{
    switch (self.flowType) {
        case STFlowTypeMyGallery:{
            [[CoreManager navigationService] switchToTabBarAtIndex:STTabBarIndexTakeAPhoto popToRootVC:YES];
            break;
        }
        case STFlowTypeUserGallery:{
            [STDataAccessUtils inviteUserToUpload:_userId withUserName:userName withCompletion:^(NSError *error) {
//                if (!error) {
//                    [[CoreManager navigationService] switchToTabBarAtIndex:STTabBarIndexHome popToRootVC:YES];
//                }
            }];
            break;
        }
            
        default:
            return;
            break;
    }
}

#pragma mark - Contextul Menu Actions

- (void)askUserToUploadAtIndex:(NSInteger)index{
    STPost *post = [self objectAtIndex:index];
    
    [STDataAccessUtils inviteUserToUpload:post.userId withUserName:post.userName withCompletion:^(NSError *error) {
        NSLog(@"Error asking user : %@", error);
    }];
    
}

- (void)deletePostAtIndex:(NSInteger)index{
    STPost *post = [self objectAtIndex:index];
    postIdToDelete = post.uuid;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Post"
                                                        message:@"Are you sure you want to delete this post?"
                                                       delegate:self cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Delete", nil];
    [alertView setTag:kDeletePostTag];
    [alertView show];

}

- (void)reportPostAtIndex:(NSInteger)index{
    STPost *post = [self objectAtIndex:index];
    
    if ([post.reportStatus integerValue] == 1) {
        [STDataAccessUtils reportPostWithId:post.uuid withCompletion:^(NSError *error) {
            NSLog(@"Post was reported with error: %@", nil);
        }];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Report Post" message:@"This post was already reported." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }

}

- (void)savePostImageLocallyAtIndex:(NSInteger)index{
    STPost *post = [self objectAtIndex:index];
    if (post.mainImageDownloaded) {
        __weak STFlowProcessor *weakSelf = self;
        [[CoreManager imageCacheService] loadPostImageWithName:post.mainImageUrl
                                            withPostCompletion:^(UIImage *origImg) {
                                                UIImageWriteToSavedPhotosAlbum(origImg, weakSelf, @selector(thisImage:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), NULL);
                                                
                                            }];
    }
}

- (void)sharePostOnfacebokAtIndex:(NSInteger)index{
    STPost *post = [self objectAtIndex:index];
    [[CoreManager facebookService] shareImageWithImageUrl:post.mainImageUrl description:nil
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

#pragma mark - Internal Helpers

-(void)updatePostIdsWithNewArray:(NSArray *)array{
    
    NSMutableArray *sheetArray = [NSMutableArray arrayWithArray:array];
    
    for (NSString *postId in array) {
        if ([_objectIds containsObject:postId]) {
            NSLog(@"Duplicate found");
            [sheetArray removeObject:postId];
            _numberOfDuplicates++;
        }
    }
    
    if (sheetArray.count > 0) {
        [_objectIds addObjectsFromArray:sheetArray];
    }
    
    //remove loading mock object
//    STPost *loadingObject = [[CoreManager postsPool] getPostWithId:kObjectUuidForLoading];
//    if (loadingObject) {
//        [_objectIds removeObject:loadingObject.uuid];
//    }

//    if (_flowType!=STFlowTypeDiscoverNearby) {
//        //add mock posts at the end of the list
//        [self addMockObjects];
//    }
    
}

//-(void)addMockObjects{
//    STBaseObj *nothingToDisplayObject = [[CoreManager postsPool] getPostWithId:kObjectUuidForNothingToDisplay];
//    if (!nothingToDisplayObject) {
//        nothingToDisplayObject = [STBaseObj mockObjNothingToDisplay];
//        [self addObjectsToObjectPool:@[nothingToDisplayObject]];
//    }
//    else
//        [_objectIds removeObject:nothingToDisplayObject.uuid];
//    
//    if (_objectIds.count == 0)
//    {
//        if(_flowType == STFlowTypeMyGallery||
//           _flowType == STFlowTypeUserGallery) {
//            [_objectIds addObject:nothingToDisplayObject.uuid];
//        }
//    }
//    else
//    {
//        if(_flowType == STFlowTypeMyGallery||
//           _flowType == STFlowTypeUserGallery) {
//        }
//    }
//    
//}

-(void)addObjectsToObjectPool:(NSArray *)objects{
    if (_flowType == STFlowTypeDiscoverNearby) {
        [[CoreManager profilePool] addProfiles:objects];
    }
    else
        [[CoreManager postsPool] addPosts:objects];
}

-(void)getMoreData{
    NSInteger offset = _objectIds.count + _numberOfDuplicates;
    NSLog(@"Offset: %ld", (long)offset);
    
//    if (_loaded == NO) {
//        STBaseObj *loadingObj = [STBaseObj mockObjectLoading];
//        [self addObjectsToObjectPool:@[loadingObj]];
//        [self.objectIds addObject:loadingObj.uuid];
//    }

    __weak STFlowProcessor *weakSelf = self;
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
                [[CoreManager localNotificationService] postNotificationName:kNotificationObjectDownloadFailed
                                                                 object:self
                                                               userInfo:nil];
            }

        }
        else
        {
            weakSelf.loaded = YES;
            if (objects.count == 0) {
                _noMoreObjectsToDownload = YES;
            }
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            BOOL suggestionsShown = [[ud valueForKey:kShowSuggestionKey] boolValue];
            if (weakSelf.flowType == STFlowTypeHome &&
                suggestionsShown == NO) {
                
                [[CoreManager localNotificationService] postNotificationName:kNotificationShowSuggestions object:self userInfo:nil];
                [ud setValue:@(YES) forKey:kShowSuggestionKey];
                [ud synchronize];
            }
//            if (_flowType != STFlowTypeMyGallery &&
//                _flowType != STFlowTypeUserGallery) {
//                [weakSelf updatePostIdsWithNewArray:[objects valueForKey:@"uuid"]];
//                [weakSelf addObjectsToObjectPool:objects];
//            }
            
            [weakSelf updatePostIdsWithNewArray:[objects valueForKey:@"uuid"]];
            [weakSelf addObjectsToObjectPool:objects];

        }
        [[CoreManager localNotificationService] postNotificationName:kNotificationObjDownloadSuccess object:self userInfo:nil];
        NSMutableArray *objToDownload = [NSMutableArray new];
        for (id ob in objects) {
            STImageCacheObj *obj = [STImageCacheObj imageCacheObjFromObj:ob];
            [objToDownload addObject:obj];
        }
        [[CoreManager imageCacheService] startImageDownloadForNewFlowType:_flowType andDataSource:objToDownload];
        
        //        }
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
            STUserProfile *userProfile = [self userProfile];
            if (userProfile == nil) {
                [STDataAccessUtils getUserProfileForUserId:_userId
                                             andCompletion:^(NSArray *objects, NSError *error) {
                                                 _userProfile = [objects firstObject];
                                                 [[CoreManager profilePool] addProfiles:@[_userProfile]];

                                                 [STDataAccessUtils getPostsForUserId:_userId
                                                                               offset:offset
                                                                       withCompletion:completion];
                                             }];
            }
            else{
                [STDataAccessUtils getPostsForUserId:_userId
                                              offset:offset
                                      withCompletion:completion];
            }
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
    if ([_objectIds containsObject:postId]) {
        STPost *post = [[CoreManager postsPool] getPostWithId:postId];
        STImageCacheObj *objToDownload = [STImageCacheObj imageCacheObjFromObj:post];
        [[CoreManager imageCacheService] startImageDownloadForNewFlowType:_flowType andDataSource:@[objToDownload]];
    }

}

- (void)postUpdated:(NSNotification *)notif{
    NSString *postId = notif.userInfo[kPostIdKey];
    if ([_objectIds containsObject:postId]) {
        [[CoreManager localNotificationService] postNotificationName:kNotificationObjUpdated object:self userInfo:@{kPostIdKey:postId}];
    }
}
- (void)postDeleted:(NSNotification *)notif{
    
    NSString *postId = notif.userInfo[kPostIdKey];
    if ([_objectIds containsObject:postId]) {
        [_objectIds removeObject:postId];
        
//        [self addMockObjects];
        
        [[CoreManager localNotificationService] postNotificationName:kNotificationObjDeleted object:self userInfo:@{kPostIdKey:postId}];
    }
}

- (void)postAdded:(NSNotification *)notif{
    NSString *userId = notif.userInfo[kUserIdKey];
    if ([userId isEqualToString:_userId]) {
        NSString *postId = notif.userInfo[kPostIdKey];
        if (![_objectIds containsObject:postId]) {
            [self updatePostIdsWithNewArray:@[postId]];
            [[CoreManager localNotificationService] postNotificationName:kNotificationObjAdded object:self userInfo:@{kPostIdKey:postId}];
        }
    }
}

-(void)newLocationHasBeenUploaded{
    [self getMoreData];
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

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kDeletePostTag) {
        if (buttonIndex==1) {
            
            [STDataAccessUtils deletePostWithId:postIdToDelete withCompletion:^(NSError *error) {
                postIdToDelete = nil;
                if (error == nil) {
                    [[[UIAlertView alloc] initWithTitle:@"Your post was deleted." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                }
                NSLog(@"Post deleted with error: %@", error);
            }];
        }
        else
            postIdToDelete = nil;
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

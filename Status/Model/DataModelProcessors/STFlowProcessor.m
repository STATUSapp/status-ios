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
#import "STAdPost.h"

#define SET_POST_AS_SEEN 0

NSString * const kNotificationObjectDownloadFailed = @"NotificationDownloadFailed";
NSString * const kNotificationObjDownloadSuccess = @"NotificationDownloadSuccess";
NSString * const kNotificationObjUpdated = @"NotificationObjUpdated";
NSString * const kNotificationObjAdded = @"NotificationObjAdded";
NSString * const kNotificationObjDeleted = @"NotificationObjDeleted";
//NSString * const kNotificationShowSuggestions = @"NotificationShowSuggestion";

NSString * const kShowSuggestionKey = @"SUGGESTIONS_SHOWED";

NSString * const kNotificationFiltersChanged = @"NotificationFiltersChanged";

NSString * const kTimeframeDaily = @"daily";
NSString * const kTimeframeWeekly = @"weekly";
NSString * const kTimeframeMonthly = @"monthly";
NSString * const kTimeframeAllTime = @"all";

NSString * const kGenderWomen = @"female";
NSString * const kGenderMen = @"male";

#ifdef DEBUG
NSInteger const kFacebookAdsTimeframe = 3;
#else
NSInteger const kFacebookAdsTimeframe = 10;
#endif
@interface STFlowProcessor ()
{
}

@property (nonatomic) STFlowType flowType;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *postId;

@property (nonatomic, strong) STUserProfile *userProfile;
@property (nonatomic, strong) NSMutableArray *objectIds;
@property (nonatomic) NSInteger numberOfDuplicates;
@property (nonatomic, assign) BOOL loaded;
@property (nonatomic, assign) BOOL noMoreObjectsToDownload;
@property (nonatomic, assign) BOOL processorInvalidated;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, strong) NSString *postIdToDelete;

@property (nonatomic, strong, readwrite) NSString *timeframeFilter;
@property (nonatomic, strong, readwrite) NSString *genderFilter;

@property (nonatomic, strong, readwrite) NSString *hashtag;
@end

@implementation STFlowProcessor

-(instancetype)initWithFlowType:(STFlowType)flowType{
    self = [super init];
    if (self) {
        self.flowType = flowType;
        _loaded = NO;
        _objectIds = [NSMutableArray new];
        if (flowType == STFlowTypePopular ||
            flowType == STFlowTypeRecent) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filtersChanged:) name:kNotificationFiltersChanged object:nil];
        }
        //the default filters are:
        // - gender: both
        // - timeframe: daily - only for popular feed
        if (flowType == STFlowTypePopular) {
            _timeframeFilter = kTimeframeDaily;
        }
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

- (instancetype)initWithFlowType:(STFlowType)flowType
                         hashtag:(NSString *)hashtag{
    self = [self initWithFlowType:flowType];
    if (self) {
        self.hashtag = hashtag;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profileUpdated:) name:STProfilePoolObjectUpdatedNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flowShouldBeReloaded:) name:kNotificationUserDidLoggedIn object:nil];
}

- (NSArray *)allObjectIds{
    return _objectIds;
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
    
    NSInteger offsetRemaining = self.objectIds.count - index;
    BOOL shouldGetNextBatch = (offsetRemaining == kStartLoadOffset) && index!=0;
    if (shouldGetNextBatch) {
        [self getMoreData];
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
    _processorInvalidated = YES;
//    _loaded = NO;
//    _numberOfDuplicates = 0;
//    _noMoreObjectsToDownload = NO;
//    _offset = 0;
//    if (_userId) {
//        [[CoreManager profilePool] removeProfilesWithIDs:@[_userId]];
//        _userProfile = nil;
//    }
//    [_objectIds removeAllObjects];
    [self getMoreData];
}

-(void)resetProcessorPropertiesIfNeeded{
    if (_processorInvalidated) {
        _processorInvalidated = NO;
        _loaded = NO;
        _numberOfDuplicates = 0;
        _noMoreObjectsToDownload = NO;
        _offset = 0;
        [_objectIds removeAllObjects];
    }
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
        _userProfile = [[CoreManager profilePool] getUserProfileWithId:_userId];

    }
    return _userProfile;
}

- (NSString *)userId{
    return _userId;
}

-(NSInteger)getLastAdPostIndex{
    STPost *post;
    NSInteger index = _objectIds.count - 1;
    while (!post && index >0) {
        STPost *currentPost = [self objectAtIndex:index];
        if ([currentPost isAdPost]) {
            post = currentPost;
        }else{
            index --;
        }
    }
    return index;
}

-(void)addFacebookAdsToArray{
    NSInteger startIndex = [self getLastAdPostIndex];
    NSInteger allObjectsCount = [_objectIds count];
    NSInteger nextIndex = startIndex + kFacebookAdsTimeframe;
    if (startIndex > 0) {
        nextIndex+=1;
    }
    while (nextIndex < allObjectsCount) {
        STAdPost *adPost = [STAdPost new];
        [_objectIds insertObject:adPost.uuid atIndex:nextIndex];
        [self addObjectsToObjectPool:@[adPost]];
        nextIndex = nextIndex+ 1 + kFacebookAdsTimeframe;
        allObjectsCount ++;
    }
}
#pragma mark - Actions

- (void)setLikeUnlikeAtIndex:(NSInteger)index
              withCompletion:(STProcessorCompletionBlock)completion{
    NSString *postId = [_objectIds objectAtIndex:index];
    STPost *post = (STPost *)[[CoreManager postsPool] getObjectWithId:postId];
    if (![post isAdPost]) {
        post.postLikedByCurrentUser = !post.postLikedByCurrentUser;
        if (post.postLikedByCurrentUser) {
            post.numberOfLikes =  @(post.numberOfLikes.integerValue+1);
        }else{
            post.numberOfLikes = @(post.numberOfLikes.integerValue-1);
        }
        [[CoreManager postsPool] addPosts:@[post]];
    }else{
        return;
    }
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
    _postIdToDelete = post.uuid;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Post"
                                                                   message:@"Are you sure you want to delete this post?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.postIdToDelete = nil;
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [STDataAccessUtils deletePostWithId:self.postIdToDelete withCompletion:^(NSError *error) {
            self.postIdToDelete = nil;
            if (error == nil) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Your post was deleted."
                                                                               message:nil
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [[CoreManager navigationService] presentAlertController:alert];
            }
            NSLog(@"Post deleted with error: %@", error);
        }];
    }]];

    [[CoreManager navigationService] presentAlertController:alert];
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
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Report Post" message:@"This post was already reported." preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [[CoreManager navigationService] presentAlertController:alert];
    }
}

- (void)savePostImageLocallyAtIndex:(NSInteger)index{
    STPost *post = [self objectAtIndex:index];
    if (post.mainImageDownloaded) {
        __weak STFlowProcessor *weakSelf = self;
        [[CoreManager imageCacheService] loadPostImageWithName:post.mainImageUrl
                                            withPostCompletion:^(UIImage *origImg) {
                                                __strong STFlowProcessor *strongSelf = weakSelf;
                                                UIImageWriteToSavedPhotosAlbum(origImg, strongSelf, @selector(thisImage:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), NULL);
                                                
                                            }];
    }
}

- (void)sharePostOnfacebokAtIndex:(NSInteger)index{
    STPost *post = [self objectAtIndex:index];
    [[CoreManager facebookService] shareImageWithImageUrl:post.mainImageUrl
                                              description:post.caption
                                                 deepLink:post.shareShortUrl
                                            andCompletion:^(id result, NSError *error) {
                                                NSString *titleAlert = nil;
                                                NSString *messageAlert = nil;
                                                if(error==nil){
                                                    titleAlert = @"Success";
                                                    messageAlert =@"Your photo was posted.";
                                                }
                                                else{
                                                    titleAlert = @"Error";
                                                    messageAlert = @"Something went wrong. You can try again later.";
                                                }
                                                UIAlertController *alert = [UIAlertController alertControllerWithTitle:titleAlert message:messageAlert preferredStyle:UIAlertControllerStyleAlert];
                                                
                                                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                                                [[CoreManager navigationService] presentAlertController:alert];

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

-(NSInteger)numberOfPostWithoutAds{
    NSInteger count = 0;
    for (NSInteger i = 0; i< _objectIds.count; i++) {
        STPost *post = [self objectAtIndex:i];
        if (![post isAdPost]) {
            count++;
        }
    }
    return count;
}

-(void)addObjectsToObjectPool:(NSArray *)objects{
    if (_flowType == STFlowTypeDiscoverNearby) {
        [[CoreManager profilePool] addProfiles:objects];
    }
    else
        [[CoreManager postsPool] addPosts:objects];
}

-(void)getMoreData{
    NSInteger offset = [self numberOfPostWithoutAds] + _numberOfDuplicates;
    if (_processorInvalidated == YES) {
        offset = 0;
    }
    NSLog(@"Offset: %ld", (long)offset);
    
//    if (_loaded == NO) {
//        STBaseObj *loadingObj = [STBaseObj mockObjectLoading];
//        [self addObjectsToObjectPool:@[loadingObj]];
//        [self.objectIds addObject:loadingObj.uuid];
//    }

    __weak STFlowProcessor *weakSelf = self;
    STDataAccessCompletionBlock completion = ^(NSArray *objects, NSError *error){
        __strong STFlowProcessor *strongSelf = weakSelf;
        if (error) {
            strongSelf.processorInvalidated = NO;
            if (strongSelf.flowType == STFlowTypeDiscoverNearby &&
                [error.domain isEqualToString:@"LOCATION_MISSING_ERROR"] &&
                error.code == 404) {
                //user has no location force an update
                [[NSNotificationCenter defaultCenter] addObserver:strongSelf selector:@selector(newLocationHasBeenUploaded) name:kNotificationNewLocationHasBeenUploaded object:nil];
                [[CoreManager locationService] forceLocationToUpdate];
            }
            else
            {
                strongSelf.loaded = YES;
                //handle error
                [[CoreManager localNotificationService] postNotificationName:kNotificationObjectDownloadFailed
                                                                 object:strongSelf
                                                               userInfo:nil];
            }

        }
        else
        {
            [strongSelf resetProcessorPropertiesIfNeeded];
            strongSelf.loaded = YES;
            if (objects.count == 0) {
                strongSelf.noMoreObjectsToDownload = YES;
            }
            if (!strongSelf.noMoreObjectsToDownload) {
                [strongSelf updatePostIdsWithNewArray:[objects valueForKey:@"uuid"]];
                [strongSelf addObjectsToObjectPool:objects];
                [strongSelf addFacebookAdsToArray];
            }

        }
        [[CoreManager localNotificationService] postNotificationName:kNotificationObjDownloadSuccess object:strongSelf userInfo:nil];
        NSMutableArray *objToDownload = [NSMutableArray new];
        for (id ob in objects) {
            STImageCacheObj *obj = [STImageCacheObj imageCacheObjFromObj:ob];
            [objToDownload addObject:obj];
        }
        [[CoreManager imageCacheService] startImageDownloadForNewFlowType:strongSelf.flowType andDataSource:objToDownload];
    };
    switch (_flowType) {
        case STFlowTypePopular:
        case STFlowTypeRecent:
        {
            [STDataAccessUtils getPostsForFlow:_flowType
                                     timeframe:_timeframeFilter
                                        gender:_genderFilter
                                        offset:offset
                                withCompletion:completion];
        }
            break;
        case STFlowTypeHome:
        {
            
            [STDataAccessUtils getPostsForFlow:_flowType
                                        offset:offset
                                withCompletion:completion];
            break;
        }
        case STFlowTypeHasttag:
        {
            [STDataAccessUtils getPostsForFlow:_flowType
                                       hashTag:_hashtag
                                        offset:offset
                                withCompletion:completion];
        }
            break;
        case STFlowTypeDiscoverNearby: {
            
            [STDataAccessUtils getNearbyPostsWithOffset:offset
                                         withCompletion:completion];
            
            break;
        }
        case STFlowTypeMyGallery:
        case STFlowTypeUserGallery:{
            STUserProfile *userProfile = [self userProfile];
            if (_processorInvalidated ||
                userProfile == nil) {
                [STDataAccessUtils getUserProfileForUserId:_userId
                                             andCompletion:^(NSArray *objects, NSError *error) {
                                                 __strong STFlowProcessor *strongSelf = weakSelf;
                                                 strongSelf.userProfile = [objects firstObject];
                                                 if (strongSelf.userProfile) {
                                                     [[CoreManager profilePool] addProfiles:@[strongSelf.userProfile]];
                                                     
                                                     [STDataAccessUtils getPostsForUserId:strongSelf.userId
                                                                                   offset:offset
                                                                           withCompletion:completion];
                                                 }
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

//-(void)flowShouldBeReloaded:(NSNotification *)notification{
//    [self reloadProcessor];
//}

-(void)filtersChanged:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    NSInteger flowType = [userInfo[@"processor_type"] integerValue];
    if (flowType == _flowType) {
        _timeframeFilter = userInfo[@"timeframe"];
        _genderFilter = userInfo[@"gender"];
        [self reloadProcessor];
    }
}

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

- (void)profileUpdated:(NSNotification *)notif{
    NSString *profileId = notif.userInfo[kUserIdKey];
    if ([_userId isEqualToString:profileId]) {
        _userProfile = [[CoreManager profilePool] getUserProfileWithId:profileId];
        for (NSString *postId in _objectIds) {
            STPost *post = [[CoreManager postsPool] getPostWithId:postId];
            post.smallPhotoUrl = _userProfile.mainImageUrl;
        }
        [[CoreManager localNotificationService] postNotificationName:kNotificationObjUpdated object:self userInfo:nil];
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
    NSString *alertTitle = nil;
    NSString *alertMessage = nil;
    
    if (error){
        alertTitle = @"Error";
        alertMessage = @"Something went wrong. You can try again later.";
    }
    else{
        alertTitle = @"Success";
        alertMessage = @"Your photo was saved.";

    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle
                                                                   message:alertMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    
    [[CoreManager navigationService] presentAlertController:alert];
}

-(void)dealloc{
    NSLog(@"Dealloc on Flow Processor");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

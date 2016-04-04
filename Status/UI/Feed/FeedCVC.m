//
//  FeedCVC.m
//  Status
//
//  Created by Cosmin Home on 06/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "FeedCVC.h"
#import "STFlowProcessor.h"
#import "STPost.h"

#import "FeedCell.h"
#import "FullCaptionFeedCell.h"
#import "STNoPhotosCell.h"
#import "FooterCell.h"

#import "STFacebookLoginController.h"
#import "STChatRoomViewController.h"
#import "STMoveScaleViewController.h"
#import "STSharePhotoViewController.h"
#import "STFriendsInviterViewController.h"

#import "STListUser.h"

#import "STUsersPool.h"
#import "STPostsPool.h"
#import "STContextualMenu.h"
#import "STImageCacheController.h"

#import "UIViewController+Snapshot.h"
#import "STUserProfileViewController.h"

@interface FeedCVC ()<STContextualMenuDelegate>
{
    CGPoint _start;
    CGPoint _end;
    BOOL _shouldForceSetSeen;

}

@property (nonatomic, strong) STFlowProcessor *feedProcessor;

@property (nonatomic, strong) NSString *userName;
@end

@implementation FeedCVC

static NSString * const normalFeedCell = @"FeedCell";
static NSString * const fullCaptionFeedCell = @"FullCaptionFeedCell";
static NSString * const loadingFeedCell = @"LoadingCell";
static NSString * const youSawAllCell = @"FooterCell";
static NSString * const noPhotosToDisplayCell = @"STNoPhotosCellIdentifier";

+ (FeedCVC *)mainFeedController{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FeedScene" bundle:nil];
    UINavigationController *navController = [storyboard instantiateInitialViewController];
    FeedCVC *feedCVC = [[navController viewControllers] firstObject];
    
    STFlowProcessor *feedProcessor = [[STFlowProcessor alloc] initWithFlowType:STFlowTypeHome];
    feedCVC.feedProcessor = feedProcessor;
    
    return feedCVC;
}

+ (FeedCVC *)singleFeedControllerWithPostId:(NSString *)postId{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FeedScene" bundle:nil];
    UINavigationController *navController = [storyboard instantiateInitialViewController];
    FeedCVC *feedCVC = [[navController viewControllers] firstObject];
    
    STFlowProcessor *feedProcessor = [[STFlowProcessor alloc] initWithFlowType:STFlowTypeSinglePost postId:postId];
    feedCVC.feedProcessor = feedProcessor;
    
    return feedCVC;
}

+ (FeedCVC *)galleryFeedControllerForUserId:(NSString *)userId
                                andUserName:(NSString *)userName{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FeedScene" bundle:nil];
    UINavigationController *navController = [storyboard instantiateInitialViewController];
    FeedCVC *feedCVC = [[navController viewControllers] firstObject];
    feedCVC.userName = userName;
    BOOL userIsMe = [[CoreManager loginService].currentUserUuid isEqualToString:userId];
    STFlowType flowType = userIsMe ? STFlowTypeMyGallery : STFlowTypeUserGallery;
    
    STFlowProcessor *feedProcessor = [[STFlowProcessor alloc] initWithFlowType:flowType userId:userId];
    feedCVC.feedProcessor = feedProcessor;
    
    return feedCVC;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processorLoaded) name:kNotificationObjDownloadSuccess object:_feedProcessor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postUpdated:) name:kNotificationObjUpdated object:_feedProcessor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postDeleted:) name:kNotificationObjDeleted object:_feedProcessor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataShouldBeReloaded:) name:STHomeFlowShouldBeReloadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postAdded:) name:kNotificationObjAdded object:_feedProcessor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSuggestions:) name: kNotificationShowSuggestions object:_feedProcessor];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notifications

- (void)processorLoaded{
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

- (void)postUpdated:(NSNotification *)notif{
    STPost *post = [[CoreManager postsPool] getPostWithId:notif.userInfo[kPostIdKey]];
    STPost *curentPost = [self getCurrentPost];
    if ([curentPost isLoadingObject] || [post.uuid isEqualToString:curentPost.uuid]) {
        [self.collectionView reloadItemsAtIndexPaths:self.collectionView.indexPathsForVisibleItems];
    }
    
}

- (void)postAdded:(NSNotification *)notif{
    [self.collectionView reloadData];
}
- (void)postDeleted:(NSNotification *)notif{
    [self.collectionView reloadData];
}

- (void)dataShouldBeReloaded:(NSNotification *)notif{
    [_feedProcessor reloadProcessor];
    [self.collectionView reloadData];
}

- (void)showSuggestions:(NSNotification *)notif{
    STFriendsInviterViewController * vc = [STFriendsInviterViewController newController];
    [self.navigationController presentViewController:[[UINavigationController alloc ]initWithRootViewController:vc] animated:NO completion:nil];

}
#pragma mark - Helpers


-(NSInteger)getCurrentIndex{
    NSArray *visibleInxPath = self.collectionView.indexPathsForVisibleItems;
    if (visibleInxPath.count == 0) {
        return NSNotFound;
    }
    return [[visibleInxPath objectAtIndex:0] row];

}

-(STPost *) getCurrentPost{
    if (self.feedProcessor.numberOfObjects == 0) {
        return nil;
    }
    STPost *post = nil;
    NSInteger index = [self getCurrentIndex];
    if (index!=NSNotFound) {
        post = [_feedProcessor objectAtIndex:index];
    }
    
    return post;
}

- (void)goToNextPostWithIndex:(NSNumber *)currentIndex{
    [[self.collectionView delegate] scrollViewWillBeginDragging:self.collectionView];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:currentIndex.integerValue inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionNone
                                        animated:YES];
    
    _shouldForceSetSeen = YES;
    [[self.collectionView delegate] scrollViewDidEndDragging:self.collectionView willDecelerate:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    //    _numberOfSeenPosts++;
    //    [self presentInterstitialControllerForIndex:_numberOfSeenPosts];
    
    _end = scrollView.contentOffset;
    if (_start.x < _end.x || _shouldForceSetSeen == YES)
    {//swipe to the right
        _shouldForceSetSeen = NO;
        CGPoint point = scrollView.contentOffset;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        NSUInteger currentIndex = point.x/screenWidth;
        NSLog(@"CurrentIndex: %lu", (unsigned long)currentIndex);
        [_feedProcessor processObjectAtIndex:currentIndex setSeenIfRequired:YES ];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _start = scrollView.contentOffset;
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numRows = [_feedProcessor numberOfObjects];
    return numRows;
}

-(NSString *)identifierForPost:(STPost *)post{
    if ([post isLoadingObject] || !post.mainImageDownloaded)
        return loadingFeedCell;
    
    if (post.isNothingToDisplayObj)
        return noPhotosToDisplayCell;
    
    if (post.isTheEndObject)
        return youSawAllCell;
    
    if (post.showFullCaption == YES) {
        return fullCaptionFeedCell;
    }
    
    return normalFeedCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.view.frame.size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    STPost *post = [_feedProcessor objectAtIndex:indexPath.row];
    NSString *identifier = [self identifierForPost:post];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    if ([cell isKindOfClass:[FeedCell class]]) {
        [(FeedCell *)cell configureCellWithPost:post];
    }
    else if ([cell isKindOfClass:[FullCaptionFeedCell class]]){
        [(FullCaptionFeedCell *)cell configureCellWithPost:post];
    }
    else if ([cell isKindOfClass:[STNoPhotosCell class]]){
        [(STNoPhotosCell *)cell configureWithUserName:_userName
                                     isTheCurrentUser:[_feedProcessor currentFlowUserIsTheLoggedInUser]];
    }
    else if ([cell isKindOfClass:[FooterCell class]]){
        UIImage *bluredImage = nil;
        if ([_feedProcessor numberOfObjects] > 0) {
            bluredImage = [self blurScreen];
        }
        else
        {
            bluredImage = [UIImage imageNamed:@"placeholder STATUS loading"];
            
        }
        [(FooterCell *)cell configureFooterWithBkImage:bluredImage];
    }
    
    return cell;
}

#pragma mark - IBACtions
- (IBAction)onLikePressed:(id)sender {
    [(UIButton *)sender setUserInteractionEnabled:NO];
    __weak FeedCVC *weakSelf = self;
    __block NSInteger index = [[[self.collectionView indexPathsForVisibleItems] firstObject] row];
    [_feedProcessor setLikeUnlikeAtIndex:index
                          withCompletion:^(NSError *error) {
                              [(UIButton *)sender setUserInteractionEnabled:YES];
                              STPost *post = [weakSelf.feedProcessor objectAtIndex:index];
                              if (post.postLikedByCurrentUser == YES &&
                                  [weakSelf.feedProcessor numberOfObjects] >= index + 1) {
                                  [weakSelf performSelector:@selector(goToNextPostWithIndex:)
                                                 withObject:@(index + 1)
                                                 afterDelay:0.25f];
                              }
                          }];
}
- (IBAction)onMessagePressed:(id)sender {
    STPost *post = [self getCurrentPost];
    
    if ([post.userId isEqualToString:[[CoreManager loginService] currentUserUuid]]) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"You cannot chat with yourself." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    STListUser *lu = (STListUser *)[[CoreManager usersPool] getUserWithId:post.userId];
    if (!lu) {
       lu = [STListUser new];
        lu.uuid = post.userId;
        lu.userName = post.userName;
        lu.thumbnail = post.smallPhotoUrl;
    }
    
    STChatRoomViewController *viewController = [STChatRoomViewController roomWithUser:lu];
    [self.navigationController pushViewController:viewController animated:YES];

}
- (IBAction)onNamePressed:(id)sender {
    if (![_feedProcessor canGoToUserProfile]) {
        //is already in user profile
        return;
    }
    
    STPost *post = [self getCurrentPost];
    
    STUserProfileViewController * userProfileVC = [STUserProfileViewController newControllerWithUserId:post.userId];
    [self.navigationController pushViewController:userProfileVC animated:YES];

}
- (IBAction)onSeeMorePressed:(id)sender {
    //TODO: dev_1_2 add animations
    STPost *post = [self getCurrentPost];
    [UIView setAnimationsEnabled:NO];
    [self.collectionView performBatchUpdates:^{
        post.showFullCaption = !post.showFullCaption;
        [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForVisibleItems]];
        [UIView setAnimationsEnabled:YES];
    } completion:nil];

}
- (IBAction)onLikesPressed:(id)sender {
}
- (IBAction)onMorePressed:(id)sender {
    STPost *post = [self getCurrentPost];
    BOOL extendedRights = NO;
    if ([post.userId isEqualToString:[CoreManager loginService].currentUserUuid]) {
        extendedRights = YES;
    }
    [STContextualMenu presentViewWithDelegate:self
                         withExtendedRights:extendedRights];
}
- (IBAction)onShadowPressed:(id)sender {
    //TODO: dev_1_2 add animations
    STPost *post = [self getCurrentPost];
    [UIView setAnimationsEnabled:NO];
    [self.collectionView performBatchUpdates:^{
        post.showFullCaption = !post.showFullCaption;
        [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForVisibleItems]];
        [UIView setAnimationsEnabled:YES];
    } completion:nil];
}

- (IBAction)onBigCameraPressed:(id)sender {
    [_feedProcessor handleBigCameraButtonActionWithUserName:_userName];
}

#pragma mark - STContextualMenuDelegate

-(void)contextualMenuAskUserToUpload{
    [_feedProcessor askUserToUploadAtIndex:[self getCurrentIndex]];
}

-(void)contextualMenuDeletePost{
    [_feedProcessor deleteObjectAtIndex:[self getCurrentIndex]];
}

-(void)contextualMenuEditPost{
    STPost *post = [self getCurrentPost];
    if (post.mainImageDownloaded == YES) {
        [[CoreManager imageCacheService] loadPostImageWithName:post.mainImageUrl withPostCompletion:^(UIImage *origImg) {
            if (origImg!=nil) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                STSharePhotoViewController *viewController = (STSharePhotoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"shareScene"];
                viewController.imgData = UIImageJPEGRepresentation(origImg, 1.f);
                viewController.bluredImgData = UIImageJPEGRepresentation(origImg, 1.f);
                viewController.post = post;
                viewController.controllerType = STShareControllerEditCaption;
                [self.navigationController pushViewController:viewController animated:YES];
            }
            
        } andBlurCompletion:nil];
    }

}

-(void)contextualMenuMoveAndScalePost{
    STPost *post = [self getCurrentPost];
    
    if (post.mainImageDownloaded == YES) {
        [[CoreManager imageCacheService] loadPostImageWithName:post.mainImageUrl withPostCompletion:^(UIImage *img) {
            if (img!=nil) {
                STMoveScaleViewController *vc = [STMoveScaleViewController newControllerForImage:img shouldCompress:NO andPost:post];
                
                [self.navigationController pushViewController:vc animated:YES];
            }
        } andBlurCompletion:nil];
        
    }
}

-(void)contextualMenuReportPost{
    [_feedProcessor reportPostAtIndex:[self getCurrentIndex]];
}

-(void)contextualMenuSavePostLocally{
    [_feedProcessor savePostImageLocallyAtIndex:[self getCurrentIndex]];
}

-(void)contextualMenuSharePostonFacebook{
    [_feedProcessor sharePostOnfacebokAtIndex:[self getCurrentIndex]];
    
}
@end

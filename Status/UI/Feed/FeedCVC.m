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
#import "STShopProduct.h"

#import "STPostImageCell.h"
#import "STPostHeader.h"
#import "STPostDetailsCell.h"

#import "UserProfileInfoCell.h"
#import "UserProfileBioCell.h"
#import "UserProfileLocationCell.h"
#import "UserProfileFriendsInfoCell.h"
#import "UserProfileNoPhotosCell.h"

#import "STFacebookLoginController.h"
#import "STChatRoomViewController.h"
#import "STMoveScaleViewController.h"
#import "STSharePhotoViewController.h"
#import "STFriendsInviterViewController.h"
#import "STSettingsViewController.h"
#import "STEditProfileViewController.h"
#import "STTabBarViewController.h"

#import "STListUser.h"

#import "STUsersPool.h"
#import "STPostsPool.h"
#import "STContextualMenu.h"
#import "STImageCacheController.h"
#import "STFollowDataProcessor.h"
#import "STLoadingView.h"

#import "UIViewController+Snapshot.h"
#import "STUsersListController.h"

#import "STShopProductCell.h"
#import "STPostShopProductsCell.h"

#import "STSnackBarService.h"
#import "STDeepLinkService.h"
#import "STNavigationService.h"

#import "STEarningsViewController.h"
#import <Photos/Photos.h>
#import "STFacebookAddCell.h"

typedef NS_ENUM(NSInteger, STScrollDirection)
{
    STScrollDirectionNone = 0,
    STScrollDirectionUp,
    STScrollDirectionDown
};

typedef NS_ENUM(NSInteger, STPostItems)
{
    STPostImage = 0,
    STPostShop,
    STPostDescription,
    STPostItemsCount
};

typedef NS_ENUM(NSInteger, STProfileItems) {
    STProfileInfo = 0,
    STProfileFriendsInfo,
    STProfileBio,
    STProfileLocation,
    STProfileNoPhotos,
    STProfileCount,
};

CGFloat const kTopButtonMargin = 4.f;
CGFloat const kTopButtonTopMargin = 4.f;
CGFloat const kTopButtonSize = 48.f;

@interface FeedCVC ()<STContextualMenuDelegate>
{
    CGPoint _start;
    BOOL _tabBarHidden;
    STScrollDirection _scrollingDirection;
    CGPoint _lastPanPoint;
    CGPoint _initialStartPoint;
}

@property (nonatomic, strong, readwrite) STFlowProcessor *feedProcessor;
@property (nonatomic, strong) STFollowDataProcessor *followProcessor;
@property (nonatomic, assign) NSInteger postForContextIndex;

@property (nonatomic, strong) NSString *userName;

@property (nonatomic, assign) BOOL isMyProfile;

@property (nonatomic, strong) STLoadingView *customLoadingView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIImageView *loadingViewImage;
@property (strong, nonatomic) IBOutlet UIView *noDataView;
@property (strong, nonatomic) IBOutlet UIView *navBarLogoView;

@end

@implementation FeedCVC

static NSString * const postHeaderIdentifier = @"STPostHeader";
static NSString * const postImageCellIdentifier = @"STPostImageCell";
static NSString * const postDetailsCellIdentifier = @"STPostDetailsCell";
static NSString * const postShopCellIdentifier = @"STPostShopProductsCell";
static NSString * const profileInfoCell = @"UserProfileInfoCell";
static NSString * const profileFriendsInfoCell = @"UserProfileFriendsInfoCell";
static NSString * const profileBioCell = @"UserProfileBioCell";
static NSString * const profileLocationCell = @"UserProfileLocationCell";
static NSString * const profileNoPhotosCell = @"UserProfileNoPhotosCell";
static NSString * const adPostIdentifier = @"STFacebookAddCell";

- (void)configureNavigationBar{
    UIViewController *currentViewController = [self.navigationController.viewControllers lastObject];
    if (self != currentViewController) {
        return;
    }
    BOOL navBarHidden = YES;
    
    if ((_feedProcessor.processorFlowType == STFlowTypeHome ||
        _feedProcessor.processorFlowType ==  STFlowTypeSinglePost)) {
        navBarHidden = NO;
        }else if (_refreshControl.refreshing == YES &&
                  _feedProcessor.processorFlowType == STFlowTypeHome){
            navBarHidden = NO;
        }

    if (navBarHidden == NO) {
        if (self == currentViewController) {
            if (_feedProcessor.processorFlowType == STFlowTypeHome) {
                self.navigationItem.titleView = _navBarLogoView;
            }
            else if (_feedProcessor.processorFlowType == STFlowTypeSinglePost)
            {
                //set tint color for the back button
                self.navigationItem.title = NSLocalizedString(@"Photo", nil);
            }
        }
    }

    [self setNeedsStatusBarAppearanceUpdate];
    [self.navigationController setNavigationBarHidden:navBarHidden animated:YES];
}

- (void)configureLoadingView{

    [self configureNavigationBar];
    
//    if ([_feedProcessor processorFlowType] == STFlowTypeHome) {
//        //use the standard loading for initial state
//        if (_feedProcessor.loading && _refreshControl.refreshing == NO) {
//            _loadingViewImage.image = [STUIHelper splashImageWithLogo:YES];
//            [self.collectionView.backgroundView removeFromSuperview];
//            self.collectionView.backgroundView = _loadingView;
//            UITabBarController *tabBarController = nil;
//            if (_containeeDelegate) {
//                tabBarController = [_containeeDelegate containeeTabBarController];
//            }
//            else
//                tabBarController = self.tabBarController;
//            
//            [((STTabBarViewController *)tabBarController) setTabBarHidden:YES];
//        }
//        else
//        {
//            [self.collectionView.backgroundView removeFromSuperview];
//            self.collectionView.backgroundView = nil;
//            UITabBarController *tabBarController = nil;
//            if (_containeeDelegate) {
//                tabBarController = [_containeeDelegate containeeTabBarController];
//            }
//            else
//                tabBarController = self.tabBarController;
//            
//            [((STTabBarViewController *)tabBarController) setTabBarHidden:NO];
//            
//        }
//    }
//    else
//    {
        //use the custom loading view
        UITabBarController *tabBarController = nil;
        if (_containeeDelegate) {
            tabBarController = [_containeeDelegate containeeTabBarController];
        }
        else
            tabBarController = self.tabBarController;
        
        [((STTabBarViewController *)tabBarController) setTabBarHidden:NO];

        if (_feedProcessor.loading) {
            [self.collectionView.backgroundView removeFromSuperview];
            self.collectionView.backgroundView = _customLoadingView;
        }
        else
        {
            [self.collectionView.backgroundView removeFromSuperview];
            self.collectionView.backgroundView = nil;
        }

//    }
}

+ (FeedCVC *)mainFeedController{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FeedScene" bundle:nil];
    UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"FEED_CVC_NAV"];
    FeedCVC *feedCVC = [[navController viewControllers] firstObject];
    
    STFlowProcessor *feedProcessor = [[STFlowProcessor alloc] initWithFlowType:STFlowTypeHome];
    feedCVC.feedProcessor = feedProcessor;
    
    return feedCVC;
}

+ (FeedCVC *)feedControllerWithFlowProcessor:(STFlowProcessor *)processor{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FeedScene" bundle:nil];
    UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"FEED_CVC_NAV"];
    FeedCVC *feedCVC = [[navController viewControllers] firstObject];
    
    feedCVC.feedProcessor = processor;
    feedCVC.shouldAddBackButton = YES;
    return feedCVC;
}

+ (FeedCVC *)singleFeedControllerWithPostId:(NSString *)postId{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FeedScene" bundle:nil];
    UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"FEED_CVC_NAV"];
    FeedCVC *feedCVC = [[navController viewControllers] firstObject];
    
    STFlowProcessor *feedProcessor = [[STFlowProcessor alloc] initWithFlowType:STFlowTypeSinglePost postId:postId];
    feedCVC.feedProcessor = feedProcessor;
    
    return feedCVC;
}

+ (FeedCVC *)galleryFeedControllerForUserId:(NSString *)userId
                                andUserName:(NSString *)userName{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FeedScene" bundle:nil];
    UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"FEED_CVC_NAV"];
    FeedCVC *feedCVC = [[navController viewControllers] firstObject];
    feedCVC.userName = userName;
    BOOL userIsMe = [[CoreManager loginService].currentUserUuid isEqualToString:userId];
    STFlowType flowType = userIsMe ? STFlowTypeMyGallery : STFlowTypeUserGallery;

    STFlowProcessor *feedProcessor = [[STFlowProcessor alloc] initWithFlowType:flowType userId:userId];
    feedCVC.feedProcessor = feedProcessor;
    
    if ([[feedProcessor userId] isEqualToString:[CoreManager loginService].currentUserUuid]) {
        feedCVC.isMyProfile = YES;
    }
    
    return feedCVC;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.feedProcessor.processorFlowType == STFlowTypeHome) {
        NSArray *redirectVC = [[CoreManager deepLinkService] redirectViewControllers];
        if (redirectVC && [redirectVC count]) {
            [[CoreManager navigationService] pushViewControllers:redirectVC
                                                 inTabbarAtIndex:STTabBarIndexHome];
        }
    }
    
    self.customLoadingView = [STLoadingView loadingViewWithSize:self.view.frame.size];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
//    layout.sectionHeadersPinToVisibleBounds = YES;
    
    if ([self.parentViewController isKindOfClass:[UINavigationController class]]) {
        self.collectionView.contentInset = UIEdgeInsetsMake(0.f, 0.f, self.tabBarController.tabBar.frame.size.height, 0.f);
    }
    
    CGRect tabBarFrame = self.tabBarController.tabBar.frame;
    _initialStartPoint = tabBarFrame.origin;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processorLoaded) name:kNotificationObjDownloadSuccess object:_feedProcessor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postUpdated:) name:kNotificationObjUpdated object:_feedProcessor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postDeleted:) name:kNotificationObjDeleted object:_feedProcessor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postAdded:) name:kNotificationObjAdded object:_feedProcessor];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSuggestions:) name: kNotificationShowSuggestions object:_feedProcessor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldGoToTop:) name:STNotificationShouldGoToTop object:nil];

    if (_feedProcessor.processorFlowType == STFlowTypeHome) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(homeFeedShouldBeReloaded:) name:STHomeFlowShouldBeReloadedNotification object:nil];
    }
    
    if (_isMyProfile) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myProfileFeedShouldBeReloaded:) name:STMyProfileFlowShouldBeReloadedNotification object:nil];
    }

    if ([self.collectionView respondsToSelector:@selector(setPrefetchingEnabled:)]) {
        self.collectionView.prefetchingEnabled = false;
    }
    
    if ([_feedProcessor loading] == NO) {
        [self.collectionView setContentOffset:CGPointZero animated:NO];
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self configureLoadingView];
    
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, 30.f);
    
    _refreshControl = [[UIRefreshControl alloc] initWithFrame:rect];
//    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull down to refresh"];
    [_refreshControl addTarget:self action:@selector(refreshControlChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.collectionView addSubview:_refreshControl];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self configureNavigationBar];
    [[CoreManager imageCacheService] changeFlowType:_feedProcessor.processorFlowType
                                          needsSort:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (_tabBarHidden) {
        CGFloat yPoints = [[UIScreen mainScreen] bounds].size.height;
        CGFloat velocityY = 1.f;
        NSTimeInterval duration = yPoints / velocityY;
        
        [UIView animateWithDuration:1.f/duration animations:^{
            CGRect tabBarFrame = self.tabBarController.tabBar.frame;
            tabBarFrame.origin.y = _initialStartPoint.y;
            [((STTabBarViewController *)self.tabBarController) setTabBarFrame:tabBarFrame];
            
        } completion:^(BOOL finished) {
            _tabBarHidden = NO;
            _scrollingDirection = STScrollDirectionNone;
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)extendedLayoutIncludesOpaqueBars{
    return YES;
}

-(BOOL)prefersStatusBarHidden{
    BOOL statusBarHidden = YES;
    if (_feedProcessor.processorFlowType == STFlowTypeHome) {
        statusBarHidden = NO;
    }else if (_refreshControl.refreshing == YES){
        statusBarHidden = NO;
    }

    return statusBarHidden;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    if (_feedProcessor.processorFlowType == STFlowTypeHome) {
        return UIStatusBarStyleDefault;
    }
    
    return UIStatusBarStyleLightContent;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notifications

- (void)processorLoaded{
    if (_refreshControl.refreshing) {
        [_refreshControl endRefreshing];
    }
    [self configureLoadingView];
    NSLog(@"Reload 1");
    [self.collectionView reloadData];
    [self.collectionView.collectionViewLayout invalidateLayout];

//    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
//    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[_feedProcessor currentOffset] inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

- (void)postUpdated:(NSNotification *)notif{
    NSLog(@"Reload 2");
    [self.collectionView reloadData];
    [self.collectionView.collectionViewLayout invalidateLayout];

    /*
    NSString *updatedPostId = notif.userInfo[kPostIdKey];
    NSArray *visibleIndexPath = [self.collectionView indexPathsForVisibleItems];
    NSMutableArray *visiblePosts = [NSMutableArray new];
    for (NSIndexPath *indexPath in visibleIndexPath) {
        NSInteger sectionIndex = [self postIndexFromIndexPath:indexPath];
        STPost *post = [_feedProcessor objectAtIndex:sectionIndex];

        if (![visiblePosts containsObject:post.uuid]) {
            [visiblePosts addObject:post.uuid];
        }
    }
    if ([visiblePosts containsObject:updatedPostId]) {
        [self.collectionView reloadItemsAtIndexPaths:self.collectionView.indexPathsForVisibleItems];
        [self.collectionView.collectionViewLayout invalidateLayout];
    }
    */
}

- (void)postAdded:(NSNotification *)notif{
    NSLog(@"Reload 3");
    [self.collectionView reloadData];
    [self.collectionView.collectionViewLayout invalidateLayout];

}
- (void)postDeleted:(NSNotification *)notif{
    NSLog(@"Reload 4");
    [self.collectionView reloadData];
    [self.collectionView.collectionViewLayout invalidateLayout];

}

- (void)homeFeedShouldBeReloaded:(NSNotification *)notif{
//    if (_isMyProfile) {
        //a new post was uploaded/edited and the profile feed should be reloaded
        [_feedProcessor reloadProcessor];
        NSLog(@"Reload 5");
        [self.collectionView reloadData];
        [self.collectionView.collectionViewLayout invalidateLayout];
//    }
}

- (void)myProfileFeedShouldBeReloaded:(NSNotification *)notif{
    if (_isMyProfile) {
        //a new post was uploaded/edited and the profile feed should be reloaded
        [_feedProcessor reloadProcessor];
        NSLog(@"Reload 6");
        [self.collectionView reloadData];
        [self.collectionView.collectionViewLayout invalidateLayout];
    }
}


- (void)showSuggestions:(NSNotification *)notif{
    STFriendsInviterViewController * vc = [STFriendsInviterViewController newController];
    [self.navigationController presentViewController:[[UINavigationController alloc ]initWithRootViewController:vc] animated:NO completion:nil];

}

- (void) shouldGoToTop:(NSNotification *)notif{
    NSInteger selectedIndex = [notif.userInfo[kSelectedTabBarKey] integerValue];
    BOOL animated = [notif.userInfo[kAnimatedTabBarKey] boolValue];
    
    BOOL shouldScrollToTop = NO;
    if (selectedIndex == STTabBarIndexHome &&
        _feedProcessor.processorFlowType == STFlowTypeHome) {
        shouldScrollToTop = YES;
    }
    
    if (selectedIndex == STTabBarIndexExplore &&
        (_feedProcessor.processorFlowType == STFlowTypeRecent ||
         _feedProcessor.processorFlowType == STFlowTypePopular)) {
            shouldScrollToTop = YES;
    }
    
    if (selectedIndex == STTabBarIndexProfile &&
        _feedProcessor.processorFlowType == STFlowTypeMyGallery) {
        shouldScrollToTop = YES;
    }
    
    if (shouldScrollToTop) {
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
        [layout invalidateLayout];
        [self.collectionView setContentOffset:CGPointZero animated:animated];

    }
    
}
#pragma mark - Helpers
- (NSInteger)postIndexFromIndexPath:(NSIndexPath *)indexPath{
    NSInteger sectionIndex = indexPath.section;
    if ([_feedProcessor processorIsAGallery] && sectionIndex > 0) {
        //substract the first section because this is the user profile section
        sectionIndex -- ;
    }
    return sectionIndex;
}

-(NSInteger)getCurrentIndexForButton:(UIButton *)button{
    NSInteger index = button.tag;
    if ([_feedProcessor processorIsAGallery]) {
        //substract the first section
        index --;
    }
    return index;
}

-(STPost *) getCurrentPostForButton:(UIButton *)button{
    if (self.feedProcessor.numberOfObjects == 0) {
        return nil;
    }
    STPost *post = nil;
    NSInteger index = [self getCurrentIndexForButton:button];
    if (index!=NSNotFound) {
        post = [_feedProcessor objectAtIndex:index];
    }
    
    return post;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([_containeeDelegate respondsToSelector:@selector(containeeEndedScrolling)]) {
        [_containeeDelegate containeeEndedScrolling];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
    
    if ([_containeeDelegate respondsToSelector:@selector(containeeStartedScrolling)]) {
        [_containeeDelegate containeeStartedScrolling];
    }

    _start = scrollView.contentOffset;
    _lastPanPoint = scrollView.contentOffset;
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    CGPoint scrollPosition = scrollView.contentOffset;
//    CGFloat offset = 0.f;

    if (scrollView.contentOffset.y < -70.f && ![_refreshControl isRefreshing]) {
        [_refreshControl beginRefreshing];
        [self refreshControlChanged:_refreshControl];
//        [_refreshControl endRefreshing];
    }

    if (_tabBarHidden) {
        CGFloat yPoints = [[UIScreen mainScreen] bounds].size.height;
        CGFloat velocityY = fabs([scrollView.panGestureRecognizer velocityInView:self.view].y);
        NSTimeInterval duration = yPoints / velocityY;
        
        [UIView animateWithDuration:1.f/duration animations:^{
            CGRect tabBarFrame = self.tabBarController.tabBar.frame;
            tabBarFrame.origin.y = _initialStartPoint.y;
            [((STTabBarViewController *)self.tabBarController) setTabBarFrame:tabBarFrame];
            
        } completion:^(BOOL finished) {
            _tabBarHidden = NO;
            _scrollingDirection = STScrollDirectionNone;
        }];
    }
}

#pragma mark - STSideBySideConatinerProtocol

- (void)containerEndedScrolling {
    self.collectionView.scrollEnabled = YES;
}

- (void)containerStartedScrolling {
    self.collectionView.scrollEnabled = NO;
}

#pragma mark <UICollectionViewDataSource>

- (void)showNoDataViewIfNeeded{
    if (_feedProcessor.loading == NO &&
        _refreshControl.refreshing == NO &&
        [_feedProcessor numberOfObjects] ==0 &&
        [_feedProcessor processorFlowType] == STFlowTypeHome) {
        [self.collectionView.backgroundView removeFromSuperview];
        self.collectionView.backgroundView = _noDataView;
        [((STTabBarViewController *)self.tabBarController) setTabBarHidden:NO];
    }
}

-(BOOL)isAdPostAtSection:(NSInteger)section{
    NSInteger sectionIndex = section;
    if ([_feedProcessor processorIsAGallery] && sectionIndex > 0) {
        //substract the first section because this is the user profile section
        sectionIndex -- ;
    }
    STPost *post = [self.feedProcessor objectAtIndex:sectionIndex];
    if ([post isAdPost]) {
        return YES;
    }
    return NO;
}
-(NSInteger)numberOfSections{
    NSInteger sectionsCount = [_feedProcessor numberOfObjects];
    if ([_feedProcessor processorIsAGallery] && ![_feedProcessor loading]) {
        //add one more section at the top
        sectionsCount ++;
    }
    return sectionsCount;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    [self showNoDataViewIfNeeded];
    
    return [self numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSInteger numItems = 0;
    
    if ([_feedProcessor processorIsAGallery] && section == 0) {
        numItems = STProfileCount;
    }else if (![self isAdPostAtSection:section]){
        numItems = STPostItemsCount;
    }else{
        numItems = 1;
    }
    
    return numItems;
}

-(NSString *)identifierForIndexPath:(NSIndexPath *)indexPath{
    if ([_feedProcessor processorIsAGallery] && indexPath.section == 0) {
        switch (indexPath.row) {
            case STProfileInfo:
                return  profileInfoCell;
                break;
            case STProfileFriendsInfo:
                return profileFriendsInfoCell;
                break;
            case STProfileBio:
                return profileBioCell;
                break;
            case STProfileLocation:
                return profileLocationCell;
                break;
            case STProfileNoPhotos:
                return profileNoPhotosCell;
                break;

        }
    }
    else if (![self isAdPostAtSection:indexPath.section])
    {
        switch (indexPath.row) {
            case STPostImage:
                return postImageCellIdentifier;
                break;
            case STPostDescription:
                return postDetailsCellIdentifier;
                break;
            case STPostShop:
                return postShopCellIdentifier;
                break;
        }
    }else{
        return adPostIdentifier;
    }
    
    NSAssert(YES, @"You should not be here");
    
    return @"";
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger sectionIndex = [self postIndexFromIndexPath:indexPath];
    NSLog(@"CurrentIndex: %lu", (unsigned long)sectionIndex);
    
    if (_feedProcessor.currentOffset < sectionIndex) {//scroling down
        [_feedProcessor processObjectAtIndex:sectionIndex setSeenIfRequired:YES];
    }
    [_feedProcessor setCurrentOffset:sectionIndex];
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([_feedProcessor processorIsAGallery] && indexPath.section == 0) {
        switch (indexPath.row) {
            case STProfileInfo:
                return [UserProfileInfoCell cellSize];
                break;
            case STProfileFriendsInfo:
            {
                return [UserProfileFriendsInfoCell cellSize];
            }
                break;
            case STProfileBio:
            {
                return [UserProfileBioCell cellSizeForProfile:[_feedProcessor userProfile]];
            }
                break;
            case STProfileLocation:
            {
                return [UserProfileLocationCell cellSizeForProfile:[_feedProcessor userProfile]];
            }
                break;
            case STProfileNoPhotos:
            {
                return [UserProfileNoPhotosCell cellSizeForNumberOfPhotos:[_feedProcessor numberOfObjects]];
            }
                break;

        }

    }
    else if (![self isAdPostAtSection:indexPath.section]){
        NSInteger sectionIndex = [self postIndexFromIndexPath:indexPath];
        STPost *post = [_feedProcessor objectAtIndex:sectionIndex];
        
        switch (indexPath.row) {
            case STPostImage:
                return [STPostImageCell celSizeForPost:post];
                break;
            case STPostDescription:
            {
                return [STPostDetailsCell cellSizeForPost:post];
            }
                break;
            case STPostShop:
            {
                if (post.showShopProducts == NO)
                    return CGSizeZero;
                else
                    return [STPostShopProductsCell cellSize];
            }
                break;
        }
    }else{
        NSInteger sectionIndex = [self postIndexFromIndexPath:indexPath];
        STAdPost *adPost = [_feedProcessor objectAtIndex:sectionIndex];
        [STFacebookAddCell cellSizeWithAdPost:adPost];
    }
    
    return CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{

    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        if ([_feedProcessor processorIsAGallery] && indexPath.section == 0) {
            return nil;
        }else if ([self isAdPostAtSection:indexPath.section]){
            return nil;
        }
        
        NSInteger sectionIndex = [self postIndexFromIndexPath:indexPath];
        STPost *post = [_feedProcessor objectAtIndex:sectionIndex];
        STPostHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:postHeaderIdentifier forIndexPath:indexPath];
            [header configureCellWithPost:post];
            [header configureForSection:indexPath.section];
        return header;
    }
    
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{

    if ([_feedProcessor processorIsAGallery] && section == 0) {
        return CGSizeZero;
    }else if ([self isAdPostAtSection:section]){
        return CGSizeZero;
    }
    return [STPostHeader headerSize];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = nil;
    NSString *identifier = [self identifierForIndexPath:indexPath];
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];

    NSInteger sectionIndex = [self postIndexFromIndexPath:indexPath];
    STPost *post = nil;
    if ([_feedProcessor numberOfObjects]) {
        post = [_feedProcessor objectAtIndex:sectionIndex];

    }
    
    if ([cell isKindOfClass:[STPostImageCell class]]) {
        [(STPostImageCell *)cell configureCellWithPost:post];
        [(STPostImageCell *)cell configureForSection:indexPath.section];
        
    }
    else if ([cell isKindOfClass:[STPostDetailsCell class]]){
        [(STPostDetailsCell *)cell configureCellWithPost:post];
        [(STPostDetailsCell *)cell configureForSection:indexPath.section];
        
    }
    else if ([cell isKindOfClass:[STPostShopProductsCell class]]){
        NSLog(@"Reload Cell indexPath: %@", indexPath);
        [(STPostShopProductsCell *)cell configureWithProducts:post.shopProducts];
    }
    else if ([cell isKindOfClass:[UserProfileInfoCell class]]){
        [(UserProfileInfoCell *)cell configureCellWithUserProfile:[_feedProcessor userProfile]];
        [(UserProfileInfoCell *)cell setBackButtonHidden:!_shouldAddBackButton];
        [(UserProfileInfoCell *)cell setSettingsButtonHidden:!_isMyProfile];
        
    }
    else if ([cell isKindOfClass:[UserProfileFriendsInfoCell class]]){
        [(UserProfileFriendsInfoCell *)cell configureForProfile:[_feedProcessor userProfile]];
    }
    else if ([cell isKindOfClass:[UserProfileBioCell class]]){
        [(UserProfileBioCell *)cell configureCellForProfile:[_feedProcessor userProfile]];
    }
    else if ([cell isKindOfClass:[UserProfileLocationCell class]]){
        [(UserProfileLocationCell *)cell configureCellForProfile:[_feedProcessor userProfile]];
    }
    else if ([cell isKindOfClass:[UserProfileNoPhotosCell class]]){
        NSString *title = @"Ask user to take a photo";
        
        if (_isMyProfile) {
            title = @"Upload first photo";
        }
        [((UserProfileNoPhotosCell *)cell).uploadPhotoButton setTitle:title forState:UIControlStateNormal];
        [((UserProfileNoPhotosCell *)cell).uploadPhotoButton setTitle:title forState:UIControlStateSelected];
        
    }else if ([cell isKindOfClass:[STFacebookAddCell class]]){
        NSInteger sectionIndex = [self postIndexFromIndexPath:indexPath];
        STAdPost *adPost = [_feedProcessor objectAtIndex:sectionIndex];
        [(STFacebookAddCell *)cell configureWithAdPost:adPost];
    }

    return cell;
}

#pragma mark - IBACtions

-(void)refreshControlChanged:(UIRefreshControl*)sender{
    NSLog(@"Value changed: %@", @(sender.refreshing));
    if (_feedProcessor.loading == NO) {
        [_feedProcessor reloadProcessor];
//        [self configureLoadingView];
//        [self.collectionView reloadData];
//        [self.collectionView.collectionViewLayout invalidateLayout];
    }
    
}

-(IBAction)onDoubleTap:(id)sender{
    CGPoint tappedPoint = [sender locationInView:self.collectionView];
    NSIndexPath *tappedCellPath = [self.collectionView indexPathForItemAtPoint:tappedPoint];
    if ([_feedProcessor processorIsAGallery] && tappedCellPath.section == 0) {
        return;
    }
    
    if (tappedCellPath)
    {
        if(tappedCellPath.item == STPostImage) {
            NSInteger postIndex = [self postIndexFromIndexPath:tappedCellPath];
            
            STPostImageCell *cell = (STPostImageCell *)[self.collectionView cellForItemAtIndexPath:tappedCellPath];
            __block STPost *post = [_feedProcessor objectAtIndex:postIndex];
            if (!post.postLikedByCurrentUser) {
                post.postLikedByCurrentUser = YES;
                [_feedProcessor setLikeUnlikeAtIndex:postIndex
                                      withCompletion:^(NSError *error) {
                                          NSLog(@"Post liked!");
                                          [cell animateLikedImage];
                                      }];
            }
            else
            {
                [cell animateLikedImage];
            }
        }
    }
}

- (IBAction)onLikePressed:(id)sender {
    [(UIButton *)sender setUserInteractionEnabled:NO];
    NSInteger index = [self getCurrentIndexForButton:sender];
    [_feedProcessor setLikeUnlikeAtIndex:index
                          withCompletion:^(NSError *error) {
                              NSLog(@"Post liked!");
                              [(UIButton *)sender setUserInteractionEnabled:YES];
                          }];
}
//- (IBAction)onMessagePressed:(id)sender {
//    
//    STPost *post = [self getCurrentPostForButton:sender];
//
//    if ([post.userId isEqualToString:[[CoreManager loginService] currentUserUuid]]) {
//        [[[UIAlertView alloc] initWithTitle:@"" message:@"You cannot chat with yourself." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
//        return;
//    }
//    STListUser *lu = (STListUser *)[[CoreManager usersPool] getUserWithId:post.userId];
//    if (!lu) {
//       lu = [STListUser new];
//        lu.uuid = post.userId;
//        lu.userName = post.userName;
//        lu.thumbnail = post.smallPhotoUrl;
//    }
//    
//    STChatRoomViewController *viewController = [STChatRoomViewController roomWithUser:lu];
//    [self.navigationController pushViewController:viewController animated:YES];
//
//}
- (IBAction)onNamePressed:(id)sender {
    if (![_feedProcessor canGoToUserProfile]) {
        //is already in user profile
        return;
    }
    
    STPost *post = [self getCurrentPostForButton:sender];
    
    FeedCVC *feedCVC = [FeedCVC galleryFeedControllerForUserId:post.userId andUserName:post.userName];
    feedCVC.shouldAddBackButton = YES;
    [self.navigationController pushViewController:feedCVC animated:YES];

}
- (IBAction)onSeeMorePressed:(id)sender {
    STPost *post = [self getCurrentPostForButton:sender];
    
    [UIView setAnimationsEnabled:NO];
    [self.collectionView performBatchUpdates:^{
        post.showFullCaption = !post.showFullCaption;
        [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForVisibleItems]];
        [UIView setAnimationsEnabled:YES];
    } completion:nil];

}
- (IBAction)onLikesPressed:(id)sender {
    STPost *post = [self getCurrentPostForButton:sender];
    STUsersListController *viewController = [STUsersListController newControllerWithUserId:post.userId postID:post.uuid andType:UsersListControllerTypeLikes];
    
    [self.navigationController pushViewController:viewController animated:YES];

}
- (IBAction)onMorePressed:(id)sender {
    STPost *post = [self getCurrentPostForButton:sender];
    BOOL extendedRights = NO;
    if ([post.userId isEqualToString:[CoreManager loginService].currentUserUuid]) {
        extendedRights = YES;
    }
    _postForContextIndex = [self getCurrentIndexForButton:sender];
    [STContextualMenu presentViewWithDelegate:self
                         withExtendedRights:extendedRights];
}
- (IBAction)onShadowPressed:(id)sender {
    STPost *post = [self getCurrentPostForButton:sender];
    [UIView setAnimationsEnabled:NO];
    [self.collectionView performBatchUpdates:^{
        post.showFullCaption = !post.showFullCaption;
        [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForVisibleItems]];
        [UIView setAnimationsEnabled:YES];
    } completion:nil];
}

- (IBAction)onBigCameraPressed:(id)sender {
    STUserProfile *up = [_feedProcessor userProfile];
    [_feedProcessor handleBigCameraButtonActionWithUserName:up.fullName];
}

- (IBAction)onBackButtonPressed:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onProfileOptionsPressed:(id)sender {
    [STContextualMenu presentProfileViewWithDelegate:self];

}

- (IBAction)onSettingsButtonPressed:(id)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    STSettingsViewController * settingsCtrl = [storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([STSettingsViewController class])];
    UINavigationController   * setttingsNav = [[UINavigationController alloc] initWithRootViewController:settingsCtrl];
    [self presentViewController: setttingsNav animated:YES completion:nil];
}

- (IBAction)onTapFollowing:(id)sender {
    STUsersListController * newVC = [STUsersListController newControllerWithUserId:[_feedProcessor userId]
                                                                            postID:nil andType:UsersListControllerTypeFollowing];
    [self.navigationController pushViewController:newVC animated:YES];
}

- (IBAction)onTapFollowers:(id)sender {
    STUsersListController * newVC = [STUsersListController newControllerWithUserId:[_feedProcessor userId]
                                                                            postID:nil andType:UsersListControllerTypeFollowers];
    [self.navigationController pushViewController:newVC animated:YES];
}

- (IBAction)onTapFollowUser:(UIButton *)followBtn {
    
    __block STUserProfile *userProfile = [_feedProcessor userProfile];
    STListUser *listUser = [userProfile listUserFromProfile];
    _followProcessor = [[STFollowDataProcessor alloc] initWithUsers:@[listUser]];
    
    listUser.followedByCurrentUser = @(![listUser.followedByCurrentUser boolValue]);
    
    __weak FeedCVC * weakSelf = self;

    [_followProcessor uploadDataToServer:@[listUser]
                          withCompletion:^(NSError *error) {
                              if (error == nil) {//success
                                  userProfile.isFollowedByCurrentUser = !userProfile.isFollowedByCurrentUser;
                                  NSLog(@"Reload 7");
                                  [weakSelf.collectionView reloadData];
                                  [weakSelf.collectionView.collectionViewLayout invalidateLayout];

                              }
                          }];
}

//- (IBAction)onTapSendMessageToUser:(id)sender {
//    
//    STListUser *lu = [[_feedProcessor userProfile] listUserFromProfile];
//    STChatRoomViewController *viewController = [STChatRoomViewController roomWithUser:lu];
//    [self.navigationController pushViewController:viewController animated:YES];
//}

- (IBAction)onMessageEditButtonPressed:(id)sender{
    if (_isMyProfile) {
        //go to Edit Profile
        [self onTapEditUserProfile:nil];
    }
    else
    {
        //go to Message to User
//        [self onTapSendMessageToUser:nil];
        
    }
}

- (IBAction)onTapEditUserProfile:(id)sender {
    STEditProfileViewController * editVC = [STEditProfileViewController newController];
    editVC.userProfile = [_feedProcessor userProfile];
    [self.navigationController pushViewController:editVC animated:YES];
}


- (void)inviteUserToUpload{
    
    STUserProfile *userProfile = [_feedProcessor userProfile];
    NSString * name = [NSString stringWithFormat:@"%@", userProfile.fullName];
    NSString * userId = [NSString stringWithFormat:@"%@", userProfile.uuid];
    
    STRequestCompletionBlock completion = ^(id response, NSError *error){
        NSInteger statusCode = [response[@"status_code"] integerValue];
        if (statusCode ==STWebservicesSuccesCod || statusCode == STWebservicesFounded) {
            NSString *message = [NSString stringWithFormat:@"Congrats, you%@ asked %@ to take a photo.We'll announce you when his new photo is on STATUS.",statusCode == STWebservicesSuccesCod?@"":@" already", name];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success" message:message preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self.navigationController presentViewController:alert animated:YES completion:nil];
        }
    };
    [STInviteUserToUploadRequest inviteUserToUpload:userId withCompletion:completion failure:nil];
}

- (IBAction)onShopButtonPressed:(id)sender {
    STPost *post = [self getCurrentPostForButton:sender];
    NSInteger index = [self getCurrentIndexForButton:sender];
    if ([_feedProcessor processorIsAGallery]) {
        index ++;
    }
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:STPostShop inSection:index];

    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView performBatchUpdates:^{
    
        if (post.showShopProducts == NO) {
            [UIView animateWithDuration:1.f animations:^{
                
                CGRect tabBarFrame = self.tabBarController.tabBar.frame;
                _initialStartPoint = tabBarFrame.origin;
                tabBarFrame.origin.y = tabBarFrame.origin.y + tabBarFrame.size.height;
                [((STTabBarViewController *)self.tabBarController) setTabBarFrame:tabBarFrame];
                
            } completion:^(BOOL finished) {
                _tabBarHidden = YES;
            }];
        }
        else
        {
            [UIView animateWithDuration:1.f animations:^{
                
                CGRect tabBarFrame = self.tabBarController.tabBar.frame;
                tabBarFrame.origin.y = _initialStartPoint.y;
                [((STTabBarViewController *)self.tabBarController) setTabBarFrame:tabBarFrame];
                
            } completion:^(BOOL finished) {
                _tabBarHidden = NO;
            }];
        }
        
        post.showShopProducts = !post.showShopProducts;
        if (post.showShopProducts == NO) {
            STPostShopProductsCell *cell = (STPostShopProductsCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            [cell setCollectionViewDelegate:nil];
        }

        
    } completion:^(BOOL finished) {
        if (post.showShopProducts) {
            //to reload the products after they were updated
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
        }

    }];

    UIButton *shopProductButton = (UIButton *)sender;
    shopProductButton.selected = !shopProductButton.selected;

}
- (IBAction)onPeopleYouShouldFollowPressed:(id)sender {
    [self showSuggestions:nil];
}

#pragma mark - STContextualMenuDelegate

-(void)contextualMenuCopyProfileUrl{
    STUserProfile *profile = [_feedProcessor userProfile];
    NSString *shareUrl = profile.profileShareUrl;
    [self addLinkToClipboard:shareUrl];
}

-(void)addLinkToClipboard:(NSString *)shareUrl{
    if (shareUrl && [shareUrl length]) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = shareUrl;
        
        [[CoreManager snackBarService] showSnackBarWithMessage:@"Copied link to clipboard"];
    }
}

-(void)contextualMenuCopyShareUrl{
    STPost *post = [_feedProcessor objectAtIndex:_postForContextIndex];
    _postForContextIndex = 0;
    NSString *shareUrl = post.shareShortUrl;
    [self addLinkToClipboard:shareUrl];
}

-(void)contextualMenuAskUserToUpload{
    [_feedProcessor askUserToUploadAtIndex:_postForContextIndex];
    _postForContextIndex = 0;
}

-(void)contextualMenuDeletePost{
    [_feedProcessor deletePostAtIndex:_postForContextIndex];
    _postForContextIndex = 0;
}

-(void)contextualMenuEditPost{
    STPost *post = [_feedProcessor objectAtIndex:_postForContextIndex];
    _postForContextIndex = 0;
    if (post.mainImageDownloaded == YES) {
        [[CoreManager imageCacheService] loadPostImageWithName:post.mainImageUrl withPostCompletion:^(UIImage *origImg) {
            if (origImg!=nil) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                STSharePhotoViewController *viewController = (STSharePhotoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"shareScene"];
                viewController.imgData = UIImageJPEGRepresentation(origImg, 1.f);
                viewController.post = post;
                viewController.controllerType = STShareControllerEditInfo;
                [self.navigationController pushViewController:viewController animated:YES];
            }
            
        }];
    }

}

-(void)contextualMenuReportPost{
    [_feedProcessor reportPostAtIndex:_postForContextIndex];
    _postForContextIndex = 0;
}

-(void)contextualMenuSavePostLocally{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        [_feedProcessor savePostImageLocallyAtIndex:_postForContextIndex];
        _postForContextIndex = 0;
    }else if (status == PHAuthorizationStatusNotDetermined){
        __weak FeedCVC *weakSelf = self;
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [weakSelf.feedProcessor savePostImageLocallyAtIndex:weakSelf.postForContextIndex];
                weakSelf.postForContextIndex = 0;
            }else{
                weakSelf.postForContextIndex = 0;
            }
        }];
    }else{
        _postForContextIndex = 0;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"You have to allow STATUS to write photos from Privacy settings." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [[CoreManager navigationService] presentAlertController:alert];
    }
}

-(void)contextualMenuSharePostonFacebook{
    [_feedProcessor sharePostOnfacebokAtIndex:_postForContextIndex];
    _postForContextIndex = 0;
    
}
@end

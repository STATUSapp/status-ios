//
//  NearbyCVC.m
//  Status
//
//  Created by Cosmin Andrus on 01/12/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "NearbyVC.h"
#import "STFlowProcessor.h"
#import "STUserProfile.h"
#import "STNearbyCell.h"
#import "STListUser.h"
#import "STChatRoomViewController.h"
#import "FeedCVC.h"
#import "STNearbyCollectionLayout.h"
#import "STTabBarViewController.h"

@interface NearbyVC ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, STNearbyLayoutDelegate>

@property (nonatomic, strong) STFlowProcessor *feedProcessor;
@property (nonatomic, strong) STNearbyCollectionLayout *layout;

@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIImageView *loadingViewImage;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end

@implementation NearbyVC

static NSString * const nearbyCell = @"STNearbyCell";

- (void)configureLoadingView{
    
    if (_feedProcessor.loading) {
        _loadingViewImage.image = [STUIHelper splashImageWithLogo:YES];
        [_loadingView removeFromSuperview];
        _loadingView.frame = self.view.frame;
        [self.view addSubview:_loadingView];
        UITabBarController *tabBarController = nil;
        if (_containeeDelegate) {
            tabBarController = [_containeeDelegate containeeTabBarController];
        }
        else
            tabBarController = self.tabBarController;
        
        [((STTabBarViewController *)tabBarController) setTabBarHidden:YES];
    }
    else
    {
        [_loadingView removeFromSuperview];
        UITabBarController *tabBarController = nil;
        if (_containeeDelegate) {
            tabBarController = [_containeeDelegate containeeTabBarController];
        }
        else
            tabBarController = self.tabBarController;
        
        [((STTabBarViewController *)tabBarController) setTabBarHidden:NO];
    }
}

+ (NearbyVC *)nearbyFeedController{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ExploreScene" bundle:nil];
    NearbyVC *nearbyVC = [storyboard instantiateViewControllerWithIdentifier:@"NEARBY_VC"];
    
    STFlowProcessor *feedProcessor = [[STFlowProcessor alloc] initWithFlowType:STFlowTypeDiscoverNearby];
    nearbyVC.feedProcessor = feedProcessor;
    
    return nearbyVC;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _layout = (STNearbyCollectionLayout *)_collectionView.collectionViewLayout;
    _layout.numberOfColumns = 2;
    _layout.cellPadding = 4.f;
    _layout.delegate = self;
    
    if (_feedProcessor.loading == NO) {
        _layout.newDataAvailable = YES;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processorLoaded) name:kNotificationObjDownloadSuccess object:_feedProcessor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postUpdated:) name:kNotificationObjUpdated object:_feedProcessor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postDeleted:) name:kNotificationObjDeleted object:_feedProcessor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataShouldBeReloaded:) name:STHomeFlowShouldBeReloadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postAdded:) name:kNotificationObjAdded object:_feedProcessor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldGoToTop:) name:STNotificationShouldGoToTop object:nil];

//    if ([_feedProcessor loading] == NO) {
//        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:[_feedProcessor currentOffset]] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
//    }
    [self configureLoadingView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - STNearbyLayoutDelegate

-(CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    STUserProfile *userProfile = [_feedProcessor objectAtIndex:indexPath.row];
    
    return [STNearbyCell cellSizeForProfile:userProfile];
}

#pragma mark - STSideBySideConatinerProtocol

- (void)containerEndedScrolling {
    self.collectionView.scrollEnabled = YES;
}

- (void)containerStartedScrolling {
    self.collectionView.scrollEnabled = NO;
}

#pragma mark - Notifications

- (void)processorLoaded{
    [self configureLoadingView];
    _layout.newDataAvailable = YES;
    [self.collectionView reloadData];
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    //    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    //    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[_feedProcessor currentOffset] inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

- (void)postUpdated:(NSNotification *)notif{
    //    [self.collectionView reloadData];
    NSString *updatedPostId = notif.userInfo[kPostIdKey];
    NSArray *visibleIndexPath = [self.collectionView indexPathsForVisibleItems];
    NSMutableArray *visibleProfiles = [NSMutableArray new];
    for (NSIndexPath *indexPath in visibleIndexPath) {
        STUserProfile *userProfile = [_feedProcessor objectAtIndex:indexPath.row];
        
        if (![visibleProfiles containsObject:userProfile.uuid]) {
            [visibleProfiles addObject:userProfile.uuid];
        }
    }
    if ([visibleProfiles containsObject:updatedPostId]) {
        _layout.newDataAvailable = YES;
        [self.collectionView reloadItemsAtIndexPaths:self.collectionView.indexPathsForVisibleItems];
        [self.collectionView.collectionViewLayout invalidateLayout];
    }
    
}

- (void)postAdded:(NSNotification *)notif{
    _layout.newDataAvailable = YES;
    [self.collectionView reloadData];
    [self.collectionView.collectionViewLayout invalidateLayout];
    
}
- (void)postDeleted:(NSNotification *)notif{
    _layout.newDataAvailable = YES;
    [self.collectionView reloadData];
    [self.collectionView.collectionViewLayout invalidateLayout];
    
}

- (void)dataShouldBeReloaded:(NSNotification *)notif{
    [_feedProcessor reloadProcessor];
    _layout.newDataAvailable = YES;
    [self.collectionView reloadData];
    [self.collectionView.collectionViewLayout invalidateLayout];
    
}

- (void) shouldGoToTop:(NSNotification *)notif{
    BOOL animated = [notif.userInfo[kAnimatedTabBarKey] boolValue];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    [layout invalidateLayout];
    [self.collectionView setContentOffset:CGPointZero animated:animated];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_feedProcessor numberOfObjects];
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index = indexPath.row;
    NSLog(@"CurrentIndex: %lu", (unsigned long)index);
    
    if ([self.collectionView.panGestureRecognizer translationInView:self.view].y <= 0){
        //scrolling down
        [_feedProcessor processObjectAtIndex:index setSeenIfRequired:YES];
    }
    
    [_feedProcessor setCurrentOffset:index];

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    STUserProfile *userProfile = [_feedProcessor objectAtIndex:indexPath.row];
    
    return [STNearbyCell cellSizeForProfile:userProfile];

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    STNearbyCell *cell = nil;
    cell = (STNearbyCell *)[collectionView dequeueReusableCellWithReuseIdentifier:nearbyCell forIndexPath:indexPath];
    
    STUserProfile *userProfile = [_feedProcessor objectAtIndex:indexPath.row];
    [cell configureCellWithUserProfile:userProfile];
    [cell configureWithIndexPath:indexPath];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    STUserProfile *userProfile = [_feedProcessor objectAtIndex:indexPath.row];
    
    FeedCVC *feedCVC = [FeedCVC galleryFeedControllerForUserId:userProfile.uuid andUserName:userProfile.fullName];
    feedCVC.shouldAddBackButton = YES;
    
    [self.navigationController pushViewController:feedCVC animated:YES];
}

- (IBAction)onTapSendMessageToUser:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    STUserProfile *userProfile = [_feedProcessor objectAtIndex:btn.tag];
    STListUser *lu = [userProfile listUserFromProfile];
    STChatRoomViewController *viewController = [STChatRoomViewController roomWithUser:lu];
    [self.navigationController pushViewController:viewController animated:YES];
}


@end

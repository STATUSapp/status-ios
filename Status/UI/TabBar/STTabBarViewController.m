//
//  STTabBarViewController.m
//  Status
//
//  Created by Silviu Burlacu on 28/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STTabBarViewController.h"
#import "STSettingsViewController.h"
#import "STChoosePhotoViewController.h"
#import "STNotificationsViewController.h"
#import "STFacebookLoginController.h"
#import "STExploreViewController.h"
#import "STLocalNotificationService.h"
#import "FeedCVC.h"
#import "STNotificationsManager.h"
#import "STNavigationService.h"

static NSString * storyboardIdentifier = @"tabBarController";
static CGFloat kTabBarHeight = 49.f;
static CGFloat kImageInset = 4.f;

@interface STTabBarViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, assign) NSInteger previousSelectedIndex;
@property (nonatomic) CGRect defaultTabBarFrame;
@property (nonatomic, strong) UINavigationController * takeAPhotoNav;

@end

@implementation STTabBarViewController

+ (instancetype)newController {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    STTabBarViewController * vc = [storyboard instantiateViewControllerWithIdentifier:storyboardIdentifier];
    [vc setupTabBar];
    vc.previousSelectedIndex = 0;
    return vc;
}

#pragma mark - Lifecycle

- (void)setupTabBar {
    
    NSMutableArray *tabBarControllers = [NSMutableArray new];
    // add home flow
    FeedCVC *homeVc = [FeedCVC mainFeedController];
    UINavigationController *homeNavCtrl = [[UINavigationController alloc] initWithRootViewController:homeVc];
//    homeNavCtrl.navigationBarHidden = YES;
    [self configureNavControllerToHandleSwipeToBackGesture:homeNavCtrl];
    
    // add explore flow
    STExploreViewController *vc = [STExploreViewController exploreViewController];
    UINavigationController *exploreNavCtrl = [[UINavigationController alloc] initWithRootViewController:vc];
    exploreNavCtrl.navigationBarHidden = YES;
    
    // add take a photo
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TakeAPhoto" bundle:nil];
    
    UIViewController *takeAPhotoVC = [storyboard instantiateViewControllerWithIdentifier:@"TAKE_PHOTO_EMPTY_VC"];
    UINavigationController * takePhotoNav = [[UINavigationController alloc] initWithRootViewController:takeAPhotoVC];
    takePhotoNav.navigationBarHidden = YES;
    
    // add message / notifications
    STNotificationsViewController * notifAndChatVC = [STNotificationsViewController newController];
    UINavigationController * notifChatNav = [[UINavigationController alloc] initWithRootViewController:notifAndChatVC];
    notifChatNav.navigationBarHidden = YES;
    [self configureNavControllerToHandleSwipeToBackGesture:notifChatNav];
    
    // add my profile
    FeedCVC *profileVC = [FeedCVC galleryFeedControllerForUserId:[[CoreManager loginService] currentUserUuid] andUserName:nil];
    UINavigationController   * profileNav = [[UINavigationController alloc] initWithRootViewController:profileVC];

    profileNav.navigationBarHidden = YES;
    [self configureNavControllerToHandleSwipeToBackGesture:profileNav];
    
    [tabBarControllers insertObject:homeNavCtrl atIndex:STTabBarIndexHome];
    [tabBarControllers insertObject:exploreNavCtrl atIndex:STTabBarIndexExplore];
    [tabBarControllers insertObject:takePhotoNav atIndex:STTabBarIndexTakeAPhoto];
    [tabBarControllers insertObject:notifChatNav atIndex:STTabBarIndexActivity];
    [tabBarControllers insertObject:profileNav atIndex:STTabBarIndexProfile];
    [self setViewControllers:tabBarControllers animated:NO];
    
    [[self.tabBar.items objectAtIndex:STTabBarIndexHome] setImage:[[UIImage imageNamed:@"home"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [[self.tabBar.items objectAtIndex:STTabBarIndexExplore] setImage:[[UIImage imageNamed:@"search"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [[self.tabBar.items objectAtIndex:STTabBarIndexTakeAPhoto] setImage:[[UIImage imageNamed:@"camera"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [[self.tabBar.items objectAtIndex:STTabBarIndexProfile] setImage:[[UIImage imageNamed:@"profile"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    [[self.tabBar.items objectAtIndex:STTabBarIndexHome] setSelectedImage:[[UIImage imageNamed:@"home-selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [[self.tabBar.items objectAtIndex:STTabBarIndexExplore] setSelectedImage:[[UIImage imageNamed:@"search-selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [[self.tabBar.items objectAtIndex:STTabBarIndexTakeAPhoto] setSelectedImage:[[UIImage imageNamed:@"camera-selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [[self.tabBar.items objectAtIndex:STTabBarIndexProfile] setSelectedImage:[[UIImage imageNamed:@"profile-selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    [self setActivityIcon];
    
    for (UITabBarItem * item in self.tabBar.items) {
        [item setTitle:nil];
        item.imageInsets = UIEdgeInsetsMake(kImageInset, 0, -1 * kImageInset, 0);
    }
    
    [self.tabBar setTintColor:[UIColor blackColor]];
    [self.tabBar setTranslucent:NO];
    
    STTabBarIndex selectedIndex = STTabBarIndexExplore;
    if ([[[CoreManager loginService] userProfile] followingCount] > 0) {
        selectedIndex = STTabBarIndexHome;
    }
    
    [self setSelectedIndex:selectedIndex];
}

-(void)handleDoubleTapOnView:(id)sender{
    
}
- (void)setActivityIcon {
    [[self.tabBar.items objectAtIndex:STTabBarIndexActivity] setImage:[[UIImage imageNamed:@"activity"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [[self.tabBar.items objectAtIndex:STTabBarIndexActivity] setSelectedImage:[[UIImage imageNamed:@"activity-selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarHeight:kTabBarHeight];
    _defaultTabBarFrame = self.tabBar.frame;
    STChoosePhotoViewController *vc = [STChoosePhotoViewController newController];
    _takeAPhotoNav = [[UINavigationController alloc] initWithRootViewController:vc];
    _takeAPhotoNav.navigationBarHidden = YES;
    // Do any additional setup after loading the view.
}

-(void)setNavigationBarHeight:(CGFloat)height{
    CGRect tabRect = self.tabBar.frame;
    CGFloat initialHeight = tabRect.size.height;
    tabRect.size.height = height;
    tabRect.origin.y = tabRect.origin.y + (initialHeight - tabRect.size.height);
    self.tabBar.frame = tabRect;

}


- (void)presentChoosePhotoVC{
    [self presentViewController:_takeAPhotoNav
                       animated:YES
                     completion:nil];
}
- (void)dismissChoosePhotoVC{
    [self goToPreviousSelectedIndex];
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}


#pragma mark - Helper

-(void)configureNavControllerToHandleSwipeToBackGesture:(UINavigationController *)navController{
    navController.interactivePopGestureRecognizer.delegate =self;
    navController.interactivePopGestureRecognizer.enabled = YES;

}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSUInteger selectedItem = [[tabBar items] indexOfObject:item];
    
    if (selectedItem == STTabBarIndexTakeAPhoto) {
        [self presentChoosePhotoVC];
    }
    else
    {
        if (_previousSelectedIndex == selectedItem) {
            UINavigationController *navController = (UINavigationController *)[self.viewControllers objectAtIndex:selectedItem];
            if ([[navController viewControllers] count] == 1) {
                [[CoreManager localNotificationService] postNotificationName:STNotificationShouldGoToTop object:nil userInfo:@{kSelectedTabBarKey:@(selectedItem), kAnimatedTabBarKey:@(YES)}];
                
            }
        }
        else if (selectedItem == STTabBarIndexActivity){
            [[CoreManager notificationsService] requestRemoteNotificationAccess];
            [[CoreManager navigationService] setBadge:0 forTabAtIndex:STTabBarIndexActivity];
        }
    }
    
}

- (BOOL)tabBarHidden {
    return self.tabBar.hidden;
}

- (void)setTabBarHidden:(BOOL)tabBarHidden
{
    self.tabBar.hidden = tabBarHidden;
}

- (void)setTabBarFrame:(CGRect)rect
{
    self.tabBar.frame = rect;
}

#pragma mark - Custom implementations for selecting the index

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (selectedIndex != STTabBarIndexTakeAPhoto) {
        _previousSelectedIndex = selectedIndex;
    }
    [self setTabBarFrame:_defaultTabBarFrame];
    [super setSelectedIndex:selectedIndex];
    [self tabBar:self.tabBar didSelectItem:self.tabBar.items[selectedIndex]];
}

- (void)setSelectedViewController:(__kindof UIViewController *)selectedViewController {
    NSInteger selectedIndex = [self.viewControllers indexOfObject:selectedViewController];
    if (selectedIndex != STTabBarIndexTakeAPhoto) {
        _previousSelectedIndex = selectedIndex;
    }
    [self setTabBarFrame:_defaultTabBarFrame];
    [super setSelectedViewController:selectedViewController];
}

- (void)goToPreviousSelectedIndex {
    [self setSelectedIndex:_previousSelectedIndex];
}

#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


@end

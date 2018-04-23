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
#import "STNotificationsManager.h"
#import "STNavigationService.h"
#import "STBarcodeScannerViewController.h"
#import "STSnackBarWithActionService.h"
#import "STLoginViewController.h"
#import "ContainerFeedVC.h"

static NSString * storyboardIdentifier = @"tabBarController";
static CGFloat kTabBarHeight = 49.f;
static CGFloat kImageInset = 4.f;

@interface STTabBarViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, assign) NSInteger previousSelectedIndex;
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
    ContainerFeedVC *homeVc = [ContainerFeedVC homeFeedController];
    UINavigationController *homeNavCtrl = [[UINavigationController alloc] initWithRootViewController:homeVc];
    [self configureNavControllerToHandleSwipeToBackGesture:homeNavCtrl];
    
    // add explore flow
    STExploreViewController *vc = [STExploreViewController exploreViewController];
    UINavigationController *exploreNavCtrl = [[UINavigationController alloc] initWithRootViewController:vc];
    exploreNavCtrl.navigationBarHidden = YES;
    
    // add take a photo
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SelectPhoto" bundle:nil];
    
    UIViewController *takeAPhotoVC = [storyboard instantiateViewControllerWithIdentifier:@"TAKE_PHOTO_EMPTY_VC"];
    UINavigationController * takePhotoNav = [[UINavigationController alloc] initWithRootViewController:takeAPhotoVC];
//    takePhotoNav.navigationBarHidden = YES;
    
    // add message / notifications
    STNotificationsViewController * notifAndChatVC = [STNotificationsViewController newController];
    UINavigationController * notifChatNav = [[UINavigationController alloc] initWithRootViewController:notifAndChatVC];
//    notifChatNav.navigationBarHidden = NO;
    [self configureNavControllerToHandleSwipeToBackGesture:notifChatNav];
    
    // add my profile
    ContainerFeedVC *profileVC = [ContainerFeedVC tabProfileController];
    UINavigationController   * profileNav = [[UINavigationController alloc] initWithRootViewController:profileVC];

//    profileNav.navigationBarHidden = YES;
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
//    [self setNavigationBarHeight:kTabBarHeight];
    [self instatiateSelectPhotoFlow];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(snackBarAction:)
                                                 name:kNotificationSnackBarAction
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLoggedOut) name:kNotificationFacebokDidLogout object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameChanged:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    
}

-(void)instatiateSelectPhotoFlow{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"SelectPhoto" bundle:[NSBundle mainBundle]];
    UIViewController *emptyVC = [storyboard instantiateViewControllerWithIdentifier:@"TAKE_PHOTO_EMPTY_VC"];
    _takeAPhotoNav = [storyboard instantiateInitialViewController];
    NSMutableArray *vcArray = [NSMutableArray arrayWithArray:_takeAPhotoNav.viewControllers];
    [vcArray insertObject:emptyVC atIndex:0];
    [_takeAPhotoNav setViewControllers:vcArray];
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
    [self instatiateSelectPhotoFlow];
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark - UINotifications

-(void)snackBarAction:(NSNotification *)notification{
    STSnackWithActionBarType type = [notification.userInfo[kNotificationSnackBarActionTypeKey] integerValue];
    if (type == STSnackWithActionBarTypeGuestMode) {
        [self presentLoginVCAnimated:YES];
    }
}

-(void)userDidLoggedOut{
    [self.selectedViewController dismissViewControllerAnimated:NO completion:nil];
    [self setSelectedIndex:STTabBarIndexExplore];
    [self presentLoginVCAnimated:YES];
}

-(void)statusBarFrameChanged:(NSNotification *)notification{
    NSLog(@"statusBarFrameChanged: %@", notification.userInfo);
    NSLog(@"status bar frame: %@", NSStringFromCGRect([UIApplication sharedApplication].statusBarFrame));
}
#pragma mark - Helper

-(STLoginViewController *)loginVC{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LoginScene" bundle:nil];
    STLoginViewController *viewController = (STLoginViewController *) [storyboard instantiateViewControllerWithIdentifier:@"loginScreen"];
    viewController.showCloseButton = YES;
    return viewController;
}

- (void)presentLoginVCAnimated:(BOOL)animated{
    STLoginViewController *viewController = [self loginVC];
    [self presentViewController:viewController
                       animated:animated
                     completion:^{
                         
                     }];
}

-(void)configureNavControllerToHandleSwipeToBackGesture:(UINavigationController *)navController{
    navController.interactivePopGestureRecognizer.delegate =self;
    navController.interactivePopGestureRecognizer.enabled = YES;

}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if ([CoreManager isGuestUser]) {
        return;
    }
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
    if (IS_IPHONE_X){
        NSLog(@"iPhone X, don't mess up the beatifull layout");
        return;
    }
    self.tabBar.frame = rect;
}

#pragma mark - Custom implementations for selecting the index

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (selectedIndex != STTabBarIndexTakeAPhoto) {
        _previousSelectedIndex = selectedIndex;
    }
    [super setSelectedIndex:selectedIndex];
    [self tabBar:self.tabBar didSelectItem:self.tabBar.items[selectedIndex]];
}

- (void)setSelectedViewController:(__kindof UIViewController *)selectedViewController {
    NSInteger selectedIndex = [self.viewControllers indexOfObject:selectedViewController];
    if (selectedIndex != STTabBarIndexTakeAPhoto) {
        _previousSelectedIndex = selectedIndex;
    }
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

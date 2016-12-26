//
//  STTabBarViewController.m
//  Status
//
//  Created by Silviu Burlacu on 28/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STTabBarViewController.h"
#import "STSettingsViewController.h"
#import "STTakeAPhotoViewController.h"
#import "STNotificationAndChatContainerViewController.h"
#import "STFacebookLoginController.h"
#import "STExploreViewController.h"
#import "STLocalNotificationService.h"
#import "FeedCVC.h"

static NSString * storyboardIdentifier = @"tabBarController";

@interface STTabBarViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, assign) NSInteger previousSelectedIndex;
@property (nonatomic, strong) UIButton *centerButton;
@property (nonatomic) CGRect defaultTabBarFrame;
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
    homeNavCtrl.navigationBarHidden = YES;
    [self configureNavControllerToHandleSwipeToBackGesture:homeNavCtrl];
    
    // add explore flow
    STExploreViewController *vc = [STExploreViewController exploreViewController];
    UINavigationController *exploreNavCtrl = [[UINavigationController alloc] initWithRootViewController:vc];
    exploreNavCtrl.navigationBarHidden = YES;

//    ExploreTVC *exploreTVC = [ExploreTVC exploreController];
//    UINavigationController *exploreNavCtrl = [[UINavigationController alloc] initWithRootViewController:exploreTVC];
//    exploreNavCtrl.navigationBarHidden = YES;
    
    // add take a photo
    STTakeAPhotoViewController * takeAPhotoVC = [STTakeAPhotoViewController newController];
    UINavigationController * takePhotoNav = [[UINavigationController alloc] initWithRootViewController:takeAPhotoVC];
    takePhotoNav.navigationBarHidden = YES;
    
    // add message / notifications
    STNotificationAndChatContainerViewController * notifAndChatVC = [STNotificationAndChatContainerViewController newController];
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
    [tabBarControllers insertObject:notifChatNav atIndex:STTabBarIndexChat];
    [tabBarControllers insertObject:profileNav atIndex:STTabBarIndexProfile];
    [self setViewControllers:tabBarControllers animated:NO];
    
    [[self.tabBar.items objectAtIndex:STTabBarIndexHome] setImage:[UIImage imageNamed:@"home"]];
    [[self.tabBar.items objectAtIndex:STTabBarIndexExplore] setImage:[UIImage imageNamed:@"search"]];
//    [[self.tabBar.items objectAtIndex:STTabBarIndexTakeAPhoto] setImage:[UIImage imageNamed:@"camera"]];
    [[self.tabBar.items objectAtIndex:STTabBarIndexProfile] setImage:[UIImage imageNamed:@"profile"]];
    
    [[self.tabBar.items objectAtIndex:STTabBarIndexHome] setSelectedImage:[UIImage imageNamed:@"home-selected"]];
    [[self.tabBar.items objectAtIndex:STTabBarIndexExplore] setSelectedImage:[UIImage imageNamed:@"search-selected"]];
//    [[self.tabBar.items objectAtIndex:STTabBarIndexTakeAPhoto] setSelectedImage:[UIImage imageNamed:@"camera"]];
    [[self.tabBar.items objectAtIndex:STTabBarIndexProfile] setSelectedImage:[UIImage imageNamed:@"profile-selected"]];
    
    
    [self setMessagesIcon];
    
    for (UITabBarItem * item in self.tabBar.items) {
        [item setTitle:nil];
        item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    }
    
    [self.tabBar setTintColor:[UIColor blackColor]];
    
//    //#f8f8fd
//    self.tabBar.tintColor = [UIColor colorWithRed:248.f/255.f
//                                            green:248.f/255.f
//                                             blue:253.f/255.f
//                                            alpha:0.9f];

}

-(void)handleDoubleTapOnView:(id)sender{
    
}
- (void)setActivityIcon {
    [[self.tabBar.items objectAtIndex:STTabBarIndexChat] setImage:[UIImage imageNamed:@"activity"]];
    [[self.tabBar.items objectAtIndex:STTabBarIndexChat] setSelectedImage:[UIImage imageNamed:@"activity-selected"]];
}

- (void)setMessagesIcon {
    [[self.tabBar.items objectAtIndex:STTabBarIndexChat] setImage:[UIImage imageNamed:@"messages"]];
    [[self.tabBar.items objectAtIndex:STTabBarIndexChat] setSelectedImage:[UIImage imageNamed:@"messages-selected"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _defaultTabBarFrame = self.tabBar.frame;
    [self addCenterButtonWithImage:[UIImage imageNamed:@"camera"]
                    highlightImage:[UIImage imageNamed:@"camera"]
                            target:self
                            action:@selector(buttonPressed:)];
    // Do any additional setup after loading the view.
}

#pragma mark - Helper

-(void)configureNavControllerToHandleSwipeToBackGesture:(UINavigationController *)navController{
    navController.interactivePopGestureRecognizer.delegate =self;
    navController.interactivePopGestureRecognizer.enabled = YES;

}

// Create a custom UIButton and add it to the center of our tab bar
- (void)addCenterButtonWithImage:(UIImage *)buttonImage highlightImage:(UIImage *)highlightImage target:(id)target action:(SEL)action
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;

    button.frame = CGRectMake(0.0, 0.0, 44.f, 44.f);
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button setImage:highlightImage forState:UIControlStateHighlighted];
    
    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
    if (heightDifference < 0) {
        button.center = self.tabBar.center;
    } else {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference/2.0;
        button.center = center;
    }
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    self.centerButton = button;
}

- (void)buttonPressed:(id)sender
{
    [self setSelectedIndex:STTabBarIndexTakeAPhoto];
    [self performSelector:@selector(doHighlight:) withObject:sender afterDelay:0];
}

- (void)doHighlight:(UIButton*)b {
    [b setHighlighted:YES];
}

- (void)doNotHighlight:(UIButton*)b {
    [b setHighlighted:NO];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if(self.tabBarController.selectedIndex != STTabBarIndexTakeAPhoto){
        [self performSelector:@selector(doNotHighlight:) withObject:_centerButton afterDelay:0];
    }
    
    NSUInteger selectedItem = [[tabBar items] indexOfObject:item];
    
    if (_previousSelectedIndex == selectedItem) {
        UINavigationController *navController = (UINavigationController *)[self.viewControllers objectAtIndex:selectedItem];
        if ([[navController viewControllers] count] == 1) {
            [[CoreManager localNotificationService] postNotificationName:STNotificationShouldGoToTop object:nil userInfo:@{kSelectedTabBarKey:@(selectedItem), kAnimatedTabBarKey:@(NO)}];
            
        }
    }
}

- (BOOL)tabBarHidden {
    return self.centerButton.hidden && self.tabBar.hidden;
}

- (void)setTabBarHidden:(BOOL)tabBarHidden
{
    self.centerButton.hidden = tabBarHidden;
    self.tabBar.hidden = tabBarHidden;
}

- (void)setTabBarFrame:(CGRect)rect
{
    CGFloat offsetY = self.tabBar.frame.origin.y - rect.origin.y;
    CGRect centerButtonFrame = _centerButton.frame;
    centerButtonFrame.origin.y = centerButtonFrame.origin.y - offsetY;
    self.centerButton.frame = centerButtonFrame;
    self.tabBar.frame = rect;
}

#pragma mark - Custom implementations for selecting the index

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    _previousSelectedIndex = self.selectedIndex;
    [self setTabBarFrame:_defaultTabBarFrame];
    [super setSelectedIndex:selectedIndex];
}

- (void)setSelectedViewController:(__kindof UIViewController *)selectedViewController {
    _previousSelectedIndex = [self.viewControllers indexOfObject:selectedViewController];
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

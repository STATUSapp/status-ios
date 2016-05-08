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
#import "STUserProfileViewController.h"
#import "STFacebookLoginController.h"
#import "ExploreTVC.h"

#import "FeedCVC.h"

static NSString * storyboardIdentifier = @"tabBarController";

@interface STTabBarViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, assign) NSInteger previousSelectedIndex;

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
    ExploreTVC *exploreTVC = [ExploreTVC exploreController];
    UINavigationController *exploreNavCtrl = [[UINavigationController alloc] initWithRootViewController:exploreTVC];
    exploreNavCtrl.navigationBarHidden = YES;

    
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
    STUserProfileViewController * profileVC = [STUserProfileViewController newControllerWithUserId:[[CoreManager loginService] currentUserUuid]];
    profileVC.shouldHideBackButton = YES;
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
    [[self.tabBar.items objectAtIndex:STTabBarIndexExplore] setImage:[UIImage imageNamed:@"explore"]];
    [[self.tabBar.items objectAtIndex:STTabBarIndexTakeAPhoto] setImage:[UIImage imageNamed:@"camera"]];
    [[self.tabBar.items objectAtIndex:STTabBarIndexChat] setImage:[UIImage imageNamed:@"message"]];
    [[self.tabBar.items objectAtIndex:STTabBarIndexProfile] setImage:[UIImage imageNamed:@"profile"]];
    
    [[self.tabBar.items objectAtIndex:STTabBarIndexHome] setSelectedImage:[UIImage imageNamed:@"home_active"]];
    [[self.tabBar.items objectAtIndex:STTabBarIndexExplore] setSelectedImage:[UIImage imageNamed:@"explore_active"]];
    [[self.tabBar.items objectAtIndex:STTabBarIndexTakeAPhoto] setSelectedImage:[UIImage imageNamed:@"camera_active"]];
    [[self.tabBar.items objectAtIndex:STTabBarIndexChat] setSelectedImage:[UIImage imageNamed:@"message_active"]];
    [[self.tabBar.items objectAtIndex:STTabBarIndexProfile] setSelectedImage:[UIImage imageNamed:@"profile_active"]];
    
    for (UITabBarItem * item in self.tabBar.items) {
        [item setTitle:nil];
    }
    
    self.tabBar.tintColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Helper

-(void)configureNavControllerToHandleSwipeToBackGesture:(UINavigationController *)navController{
    navController.interactivePopGestureRecognizer.delegate =self;
    navController.interactivePopGestureRecognizer.enabled = YES;

}

#pragma mark - Custom implementations for selecting the index



- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    _previousSelectedIndex = self.selectedIndex;
    [super setSelectedIndex:selectedIndex];
}

- (void)setSelectedViewController:(__kindof UIViewController *)selectedViewController {
    _previousSelectedIndex = self.selectedIndex;
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

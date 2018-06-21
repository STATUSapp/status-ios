//
//  STNavigationService.m
//  Status
//
//  Created by Andrus Cosmin on 29/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STNavigationService.h"
#import "STLoginViewController.h"
#import "AppDelegate.h"
#import "FeedCVC.h"

#import "STImagePickerService.h"
#import "STTabBarViewController.h"
#import "STImagePickerService.h"
#import "STMoveScaleViewController.h"

#import "STPost.h"
#import "STFlowTemplate.h"
#import "STPostsPool.h"
#import "STSharePhotoViewController.h"
#import "STLocalNotificationService.h"
#import "STLoginService.h"

@interface STNavigationService ()

@end

@implementation STNavigationService
-(instancetype)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLoggedIn:) name:kNotificationUserDidLoggedIn object:nil];
    }
    return self;
}

#pragma mark - Methods

+ (STTabBarViewController *)appTabBar {
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    if ([[window rootViewController] isKindOfClass:[STTabBarViewController class]]) {
        STTabBarViewController *tbc = (STTabBarViewController *)[window rootViewController];
        return tbc;
    }
    
    return nil;
}

-(void)setBadge:(NSInteger)badge
  forTabAtIndex:(NSInteger)index{
    
    NSString *badgeString = nil;
    if (badge > 0) {
        if (badge > 99)
            badgeString = @"99+";
        else
            badgeString = [NSString stringWithFormat:@"%ld", (long)badge];
    }
    
    [[[STNavigationService appTabBar].viewControllers objectAtIndex:index] tabBarItem].badgeValue = badgeString;
}

-(void)switchToTabBarAtIndex:(NSInteger)index
                 popToRootVC:(BOOL)popToRoot{
    [[STNavigationService appTabBar] setSelectedIndex:index];
    if (popToRoot) {
        UINavigationController *navCtrl = (UINavigationController *)[[[STNavigationService appTabBar] viewControllers] objectAtIndex:index];
        [navCtrl popToRootViewControllerAnimated:YES];
    }
}

- (void)dismissChoosePhotoVC {
    [[STNavigationService appTabBar] dismissChoosePhotoVC];
}

- (void)goToNotifications {
    [self switchToTabBarAtIndex:STTabBarIndexActivity popToRootVC:YES];
    [[CoreManager localNotificationService] postNotificationName:STNotificationSelectNotificationsScreen object:nil userInfo:nil];
}

- (void)goToChat {
    [self switchToTabBarAtIndex:STTabBarIndexActivity popToRootVC:YES];
    [[CoreManager localNotificationService] postNotificationName:STNotificationSelectChatScreen object:nil userInfo:nil];
}

- (void)showActivityIconOnTabBar {
    [[STNavigationService appTabBar] setActivityIcon];
}

//- (void)showMessagesIconOnTabBar {
//    [[STNavigationService appTabBar] setMessagesIcon];
//}

- (void)presentTabBarControllerWithLoginOnTop:(BOOL)showLoginOnTop{
    NSLog(@"Tabbar Controller presented");
    AppDelegate *appDel=(AppDelegate *)[UIApplication sharedApplication].delegate;
    STTabBarViewController * tabBar = [STTabBarViewController newController];
    tabBar.delegate = appDel;
    [appDel.window setRootViewController:tabBar];
    if (showLoginOnTop) {
//        [tabBar presentLoginVCAnimated:NO];
        [self presentLoginView];
    }
}

- (void)presentLoginView{
    AppDelegate *appDel=(AppDelegate *)[UIApplication sharedApplication].delegate;
    UIView *loginView = [appDel.window viewWithTag:kLoginViewTag];
    if (loginView) {
        //already on screen, do nothing
    }else{
        STLoginView *loginView = [CoreManager loginService].loginView;
        [appDel.window addSubview:loginView];
        [appDel.window bringSubviewToFront:loginView];
        [loginView animateIn];
    }
}

- (void)presentInstagramLogin{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LoginScene" bundle:nil];
    UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"INSTA_LOGIN_NAV"];
    UIViewController *viewController = [STNavigationService viewControllerForSelectedTab];
    [viewController presentViewController:navController animated:YES completion:nil];
}
- (void)resetTabBarStacks{
    //TODO: dev_1_2 should we reset some nav controller?
}

-(void)pushViewController:(UIViewController *) vc
          inTabbarAtIndex:(NSInteger)index
      keepThecurrentStack:(BOOL)keepTheStack{
    
    [self switchToTabBarAtIndex:index popToRootVC:!keepTheStack];
    if (vc) {
        [self pushViewController:vc inTabBarIndex:index animated:YES];
    }
}

#pragma mark - NSNOtifications
- (void)userDidLoggedIn:(NSNotification *)notification{
    BOOL manualLogout = [notification.userInfo[kManualLogoutKey] boolValue];
    [self presentTabBarControllerWithLoginOnTop:manualLogout];
}

#pragma mark - Helpers

-(NSInteger)selectedTabBarIndex{
    return [STNavigationService appTabBar].selectedIndex;
}

-(void)pushViewController:(UIViewController *)vc
            inTabBarIndex:(NSInteger)index
                 animated:(BOOL)animated{
    UINavigationController *navCtrl = (UINavigationController *)[[[STNavigationService appTabBar] viewControllers] objectAtIndex:index];
    [navCtrl pushViewController:vc animated:animated];

}

-(void)pushViewControllers:(NSArray <UIViewController *> *) arrayVC
           inTabbarAtIndex:(NSInteger)index{
    [[STNavigationService appTabBar] setSelectedIndex:index];
    UINavigationController *navCtrl = (UINavigationController *)[[[STNavigationService appTabBar] viewControllers] objectAtIndex:index];
    [navCtrl popToRootViewControllerAnimated:NO];
    NSMutableArray *viewControllers = [[navCtrl viewControllers] mutableCopy];
    [viewControllers addObjectsFromArray:arrayVC];
    [navCtrl setViewControllers:viewControllers animated:YES];

}

-(void)presentAlertController:(UIAlertController *)alert{
    STTabBarViewController *tbc = [STNavigationService appTabBar];
    UINavigationController *navCtrl = (UINavigationController *)[[tbc viewControllers] objectAtIndex:tbc.selectedIndex];
    [navCtrl presentViewController:alert
                          animated:YES
                        completion:nil];
}

+ (UIViewController *)viewControllerForSelectedTab{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    UITabBarController *tbc = (UITabBarController *)[window rootViewController];
    UINavigationController *navCtrl = (UINavigationController *)[tbc selectedViewController];
    return [[navCtrl viewControllers] lastObject];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

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
#import "STImageCacheController.h"
#import "STSharePhotoViewController.h"
#import "STLocalNotificationService.h"

@interface STNavigationService ()

@end

@implementation STNavigationService
-(instancetype)init{
    self = [super init];
    if (self) {
                
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLoggedIn) name:kNotificationUserDidLoggedIn object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidRegister) name:kNotificationUserDidRegister object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLoggedOut) name:kNotificationUserDidLoggedOut object:nil];
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

- (void)goToPreviousTabBarScene {
    [[STNavigationService appTabBar] goToPreviousSelectedIndex];
}

- (void)goToNotifications {
    [self switchToTabBarAtIndex:STTabBarIndexChat popToRootVC:YES];
    [[CoreManager localNotificationService] postNotificationName:STNotificationSelectNotificationsScreen object:nil userInfo:nil];
}

- (void)goToChat {
    [self switchToTabBarAtIndex:STTabBarIndexChat popToRootVC:YES];
    [[CoreManager localNotificationService] postNotificationName:STNotificationSelectChatScreen object:nil userInfo:nil];
}

- (void)showActivityIconOnTabBar {
    [[STNavigationService appTabBar] setActivityIcon];
}

- (void)showMessagesIconOnTabBar {
    [[STNavigationService appTabBar] setMessagesIcon];
}

- (void)presentLoginScreen{
    AppDelegate *appDel=(AppDelegate *)[UIApplication sharedApplication].delegate;
    if ([appDel.window.rootViewController isKindOfClass:[STLoginViewController class]]) {
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LoginScene" bundle:nil];
    STLoginViewController *viewController = (STLoginViewController *) [storyboard instantiateViewControllerWithIdentifier:@"loginScreen"];
    [appDel.window setRootViewController:viewController];
    
}

- (void)presentTabBarController{
    NSLog(@"Tabbar Controller presented");
    AppDelegate *appDel=(AppDelegate *)[UIApplication sharedApplication].delegate;
    STTabBarViewController * tabBar = [STTabBarViewController newController];
    [appDel.window setRootViewController:tabBar];
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
- (void)userDidLoggedIn{
    [self presentTabBarController];
}

- (void)userDidRegister{
    [self presentTabBarController];
}

- (void)userDidLoggedOut{
    [self presentLoginScreen];
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

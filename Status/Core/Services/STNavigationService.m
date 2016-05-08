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

#import "STImagePickerController.h"
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flowWasSelectedFromFooter:) name:STFooterFlowsNotification object:nil];

    }
    return self;
}

#pragma mark - Methods

- (STTabBarViewController *)appTabBar {
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    STTabBarViewController *tbc = (STTabBarViewController *)[window rootViewController];
    return tbc;
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
    
    [[self.appTabBar.viewControllers objectAtIndex:index] tabBarItem].badgeValue = badgeString;
}

-(void)switchToTabBarAtIndex:(NSInteger)index
                 popToRootVC:(BOOL)popToRoot{
    [self.appTabBar setSelectedIndex:index];
    if (popToRoot) {
        UINavigationController *navCtrl = (UINavigationController *)[[self.appTabBar viewControllers] objectAtIndex:index];
        [navCtrl popToRootViewControllerAnimated:YES];
    }
}

- (void)goToPreviousTabBarScene {
    [self.appTabBar goToPreviousSelectedIndex];
}

- (void)showActivityIconOnTabBar {
    [self.appTabBar setActivityIcon];
}

- (void)showMessagesIconOnTabBar {
    [self.appTabBar setMessagesIcon];
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

-(void) flowWasSelectedFromFooter:(NSNotification *)notif{
    NSString *flowType = [[notif userInfo] objectForKey:kFlowTypeKey];
    if ([flowType isEqualToString:@"home"]) {
        //go to home tab and refresh the data
        [self switchToTabBarAtIndex:STTabBarIndexHome popToRootVC:YES];
        [[CoreManager localNotificationService] postNotificationName:STHomeFlowShouldBeReloadedNotification object:nil userInfo:nil];
        
    }
    else if ([flowType isEqualToString:@"popular"]){
        [[CoreManager navigationService] switchToTabBarAtIndex:STTabBarIndexExplore popToRootVC:YES];

    }
    else if ([flowType isEqualToString:@"recent"]){
                [[CoreManager navigationService] switchToTabBarAtIndex:STTabBarIndexExplore popToRootVC:YES];
    }
    else if ([flowType isEqualToString:@"nearby"]){
                [[CoreManager navigationService] switchToTabBarAtIndex:STTabBarIndexExplore popToRootVC:YES];
    }

}

#pragma mark - Helpers

-(NSInteger)selectedTabBarIndex{
    return self.appTabBar.selectedIndex;
}

-(void)pushViewController:(UIViewController *)vc
            inTabBarIndex:(NSInteger)index
                 animated:(BOOL)animated{
    UINavigationController *navCtrl = (UINavigationController *)[[self.appTabBar viewControllers] objectAtIndex:index];
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

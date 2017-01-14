//
//  STNavigationService.h
//  Status
//
//  Created by Andrus Cosmin on 29/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STTabBarViewController;

@interface STNavigationService : NSObject

- (void)presentLoginScreen;
- (void)presentTabBarController;
- (void)resetTabBarStacks;

-(void)setBadge:(NSInteger)badge
  forTabAtIndex:(NSInteger)index;

-(void)switchToTabBarAtIndex:(NSInteger)index
                 popToRootVC:(BOOL)popToRoot;

- (void)goToPreviousTabBarScene;

- (void)goToNotifications;

- (void)goToChat;

- (void)showActivityIconOnTabBar;

- (void)showMessagesIconOnTabBar;

-(void)pushViewController:(UIViewController *) vc
          inTabbarAtIndex:(NSInteger)index
      keepThecurrentStack:(BOOL)keepTheStack;

+ (UIViewController *)viewControllerForSelectedTab;

+ (STTabBarViewController *)appTabBar;
@end

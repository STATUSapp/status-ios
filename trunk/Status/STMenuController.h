//
//  STMenuController.h
//  Status
//
//  Created by Cosmin Andrus on 28/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STMenuController : NSObject

- (void)goHome;
- (void)goSettings;
- (void)goTutorial;
- (void)goMyProfile;
- (void)goFriendsInviter;
- (void)goNearby;

- (void)hideMenu;
- (void)showMenuForController:(UIViewController *)parrentVC;

+ (STMenuController *) sharedInstance;
+ (UIImage *)snapshotForViewController:(UIViewController *)vc;
@end

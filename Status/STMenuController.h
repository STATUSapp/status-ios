//
//  STMenuController.h
//  Status
//
//  Created by Cosmin Andrus on 28/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STFlowTemplateViewController;

@interface STMenuController : NSObject

- (void)goHome;
- (void)goPopular;
- (void)goRecent;
- (void)goSettings;
- (void)goTutorial;
- (void)goMyProfile;
- (void)goFriendsInviter;
- (void)goNearby;
- (void)goNotification;

- (void)hideMenu;
- (void)showMenuForController:(UIViewController *)parrentVC;

+ (STMenuController *) sharedInstance;
+ (UIImage *)snapshotForViewController:(UIViewController *)vc;
+(UIImage *)blurScreen:(UIViewController *)vc;
- (STFlowTemplateViewController *)appMainController;

@end

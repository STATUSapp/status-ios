//
//  STMenuController.m
//  Status
//
//  Created by Cosmin Andrus on 28/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STMenuController.h"
#import "STMenuView.h"
#import "UIImage+ImageEffects.h"
#import "STSettingsViewController.h"
#import "STTutorialPresenterViewController.h"
#import "STInviteController.h"
#import "STUserProfileViewController.h"
#import "STFacebookLoginController.h"
#import "STLocationManager.h"
#import "STNearbyController.h"
#import "STNotificationsViewController.h"
#import "STSuggestionsViewController.h"

#import "STFriendsInviterViewController.h"

#import "AppDelegate.h"
#import "STUnseenPostsCountRequest.h"

@interface STMenuController()

@property(nonatomic, strong)STMenuView *menuView;
@property(nonatomic, strong)UIViewController *currentVC;
@property(nonatomic, strong)STNearbyController *nearbyCtrl;

@end

@implementation STMenuController

+(STMenuController *) sharedInstance{
    static STMenuController *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        if (_menuView==nil) {
            NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"STMenuView" owner:self options:nil];
            _menuView = (STMenuView *)[views firstObject];
            _menuView.translatesAutoresizingMaskIntoConstraints = NO;
            _menuView.notificationBadge.layer.cornerRadius =
            _menuView.homeNotifBadge.layer.cornerRadius =
            _menuView.populatNotifBadge.layer.cornerRadius =
            _menuView.recentNotifBadge.layer.cornerRadius = 7.f;
            
        }

    }
    
    return self;
}

-(void)resetCurrentVC:(UIViewController *)otherVC{
    _currentVC = otherVC;
}

- (NSString *)computedStringForBadge:(NSInteger)badge {
    NSString *computedString = @" 99 + ";
    if (badge <= 99) {
        computedString = [NSString stringWithFormat:@"%@ %zd %@",badge>10?@"":@" ", badge,badge>10?@"":@" "];
    }
    return computedString;
}

- (void)showMenuForController:(UIViewController *)parrentVC{
    
    _currentVC = parrentVC;
    
    _menuView.alpha = 0.f;
    _menuView.blurBackground.image = [STMenuController blurScreen:_currentVC];
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    /*
    NSInteger notifNumber = app.badgeNumber;
    if (notifNumber > 0) {
        _menuView.notificationBadge.text = [NSString stringWithFormat:@"%@ %zd %@",notifNumber>10?@"":@" ",notifNumber,notifNumber>10?@"":@" "];
        _menuView.notificationBadge.hidden = NO;
    }
    else{
        _menuView.notificationBadge.hidden = YES;
    }
     */
    _menuView.homeNotifBadge.hidden =
    _menuView.recentNotifBadge.hidden =
    _menuView.populatNotifBadge.hidden = YES;

    [parrentVC.view addSubview:_menuView];
    
    [self addContraintForMenu];
    
    [UIView animateWithDuration:0.33 animations:^{
        _menuView.alpha = 1.f;
    }];
    
    [STUnseenPostsCountRequest getUnseenCountersWithCompletion:^(id response, NSError *error) {
        if ([response[@"status_code"] integerValue] == 200) {
            NSInteger unseenHomePosts = [response[@"unseenHomePosts"] integerValue];
            NSInteger unseenPopularPosts = [response[@"unseenPopularPosts"] integerValue];
            NSInteger unseenRecentPosts = [response[@"unseenRecentPosts"] integerValue];
            
            if (unseenHomePosts > 0) {
                _menuView.homeNotifBadge.text = [self computedStringForBadge:unseenHomePosts];;
                _menuView.homeNotifBadge.hidden = NO;
            }
            else{
                _menuView.homeNotifBadge.hidden = YES;
            }
            
            if (unseenPopularPosts > 0) {
                _menuView.populatNotifBadge.text = [self computedStringForBadge:unseenPopularPosts];
                _menuView.populatNotifBadge.hidden = NO;
            }
            else{
                _menuView.populatNotifBadge.hidden = YES;
            }

            if (unseenRecentPosts > 0) {
                _menuView.recentNotifBadge.text = [self computedStringForBadge:unseenRecentPosts];
                _menuView.recentNotifBadge.hidden = NO;
            }
            else{
                _menuView.recentNotifBadge.hidden = YES;
            }

        }
    } failure:^(NSError *error) {
        NSLog(@"Load counters error: %@", error);
    }];
}

-(void)hideMenu{
//    _currentVC = nil;
    [UIView animateWithDuration:0.33 animations:^{
        _menuView.alpha = 0.f;
    } completion:^(BOOL finished) {
        _menuView.blurBackground.image = nil;
        [_menuView removeFromSuperview];
    }];
}

#pragma mark - MenuView Actions
//TODO: dev_1_2 make sure all those are moved in the right place

/*
- (void)goHome{
    [self hideMenu];
    STFlowTemplateViewController *vc = nil;
    for (UIViewController *viewCtrl in _currentVC.navigationController.viewControllers) {
        if ([viewCtrl isKindOfClass:[STFlowTemplateViewController class]]) {
            if ([(STFlowTemplateViewController*)viewCtrl flowType] == STFlowTypeHome) {
                vc = (STFlowTemplateViewController *)viewCtrl;
                break;
            }
        }
    }
    if (vc!=nil) {
        [_currentVC.navigationController popToViewController:vc animated:YES];
    }
    else{
        vc = [STFlowTemplateViewController getFlowControllerWithFlowType:STFlowTypeHome];
        [_currentVC.navigationController pushViewController:vc animated:YES];
    }
}

- (void)goPopular{
    [self hideMenu];
    STFlowTemplateViewController *vc = nil;
    for (UIViewController *viewCtrl in _currentVC.navigationController.viewControllers) {
        if ([viewCtrl isKindOfClass:[STFlowTemplateViewController class]]) {
            if ([(STFlowTemplateViewController*)viewCtrl flowType] == STFlowTypePopular) {
                vc = (STFlowTemplateViewController *)viewCtrl;
                break;
            }
        }
    }
    if (vc!=nil) {
        [_currentVC.navigationController popToViewController:vc animated:YES];
    }
    else{
        vc = [STFlowTemplateViewController getFlowControllerWithFlowType:STFlowTypePopular];
        [_currentVC.navigationController pushViewController:vc animated:YES];
    }

}

- (void)goRecent{
    [self hideMenu];
    STFlowTemplateViewController *vc = nil;
    for (UIViewController *viewCtrl in _currentVC.navigationController.viewControllers) {
        if ([viewCtrl isKindOfClass:[STFlowTemplateViewController class]]) {
            if ([(STFlowTemplateViewController*)viewCtrl flowType] == STFlowTypeRecent) {
                vc = (STFlowTemplateViewController *)viewCtrl;
                break;
            }
        }
    }
    if (vc!=nil) {
        [_currentVC.navigationController popToViewController:vc animated:YES];
    }
    else{
        vc = [STFlowTemplateViewController getFlowControllerWithFlowType:STFlowTypeRecent];
        [_currentVC.navigationController pushViewController:vc animated:YES];
    }
}

- (void)goSettings{
    [self resetNavigationControllerStack];
    [self hideMenu];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    STSettingsViewController * settingsCtrl = [storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([STSettingsViewController class])];
    UINavigationController   * setttingsNav = [[UINavigationController alloc] initWithRootViewController:settingsCtrl];
    [_currentVC presentViewController: setttingsNav animated:YES completion:nil];
}

- (void)goTutorial{
    [self resetNavigationControllerStack];
    [self hideMenu];
    STTutorialPresenterViewController * tutorialVC = [STTutorialPresenterViewController newInstance];
    tutorialVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [_currentVC presentViewController:tutorialVC animated:YES completion:nil];
}
- (void)goMyProfile{
    [self resetNavigationControllerStack];
    [self hideMenu];
    STUserProfileViewController * userProfileVC = [STUserProfileViewController newControllerWithUserId:[[CoreManager loginService] currentUserUuid]];
    userProfileVC.isMyProfile = YES;
    [_currentVC.navigationController pushViewController:userProfileVC animated:YES];
}
- (void)goFriendsInviter {
    [self resetNavigationControllerStack];
    [self hideMenu];
    STFriendsInviterViewController * inviteFriendsVC = [STFriendsInviterViewController newController];
    [_currentVC.navigationController pushViewController:inviteFriendsVC animated:NO];
}
- (void)goFollowPeople {
    [self resetNavigationControllerStack];
    [self hideMenu];
    STSuggestionsViewController * suggestionsVC = [STSuggestionsViewController instatiateWithDelegate:nil andFollowTyep:STFollowTypeFriendsAndPeople];
    [_currentVC.navigationController pushViewController:suggestionsVC animated:NO];
}
- (void)goNotification{
    [self resetNavigationControllerStack];
    [self hideMenu];
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    STNotificationsViewController *notifController = [storyboard instantiateViewControllerWithIdentifier: @"notificationScene"];
    [_currentVC.navigationController pushViewController:notifController animated:YES];

}
- (void)goNearby {
    
    if (![STLocationManager locationUpdateEnabled]) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"You need to allow STATUS to access your location in order to see nearby friends." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    else
    {
        [self resetNavigationControllerStack];
        [self hideMenu];
        [_currentVC.navigationController popToRootViewControllerAnimated:NO];
//        STFlowTemplateViewController *flowCtrl = [_currentVC.storyboard instantiateViewControllerWithIdentifier: @"flowTemplate"];
//        flowCtrl.flowType = STFlowTypeDiscoverNearby;
//        [_currentVC.navigationController pushViewController:flowCtrl animated:YES];
        _nearbyCtrl = [[STNearbyController alloc] init];
        [_nearbyCtrl pushNearbyFlowFromController:_currentVC withCompletionBlock:^(NSError *error) {
            if (error) {
                [[[UIAlertView alloc] initWithTitle:@"Something went wrong..." message:@"Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }
        }];
    }

}

- (void)resetNavigationControllerStack {
    if (_currentVC == nil) {
        _currentVC = [self appMainController];
    }
    
    UINavigationController * navController = _currentVC.navigationController;
    _currentVC = _currentVC.navigationController.viewControllers.firstObject;
    [navController popToRootViewControllerAnimated:NO];
}
*/

- (STFlowTemplateViewController *)appMainController {
    AppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    
    UIViewController * appMainController = appDelegate.window.rootViewController;
    if ([appMainController isKindOfClass:[UINavigationController class]]) {
        appMainController = [(UINavigationController *)appMainController viewControllers].firstObject;
    }
    
    return (STFlowTemplateViewController *)appMainController;
}

//#pragma mark - STTutorialDelegate
//
//-(void)tutorialDidDissmiss{
//    if ([[STInviteController sharedInstance] shouldInviteBeAvailable]) {
//        [self goFriendsInviter];
//    }
//}

-(void)addContraintForMenu{
    [_currentVC.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:_menuView
                              attribute:NSLayoutAttributeTop
                              relatedBy:NSLayoutRelationEqual
                              toItem:_currentVC.topLayoutGuide
                              attribute:NSLayoutAttributeTop
                              multiplier:1.f
                              constant:0]];
    [_currentVC.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:_menuView
                              attribute:NSLayoutAttributeBottom
                              relatedBy:NSLayoutRelationEqual
                              toItem:_currentVC.bottomLayoutGuide
                              attribute:NSLayoutAttributeBottom
                              multiplier:1.f
                              constant:0]];
    [_currentVC.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:_menuView
                              attribute:NSLayoutAttributeTrailing
                              relatedBy:NSLayoutRelationEqual
                              toItem:_currentVC.view
                              attribute:NSLayoutAttributeTrailing
                              multiplier:1.f
                              constant:0]];
    [_currentVC.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:_menuView
                              attribute:NSLayoutAttributeLeading
                              relatedBy:NSLayoutRelationEqual
                              toItem:_currentVC.view
                              attribute:NSLayoutAttributeLeading
                              multiplier:1.f
                              constant:0]];
    _menuView.centerYConstraint = [NSLayoutConstraint
                                   constraintWithItem:_menuView.itemsView
                                   attribute:NSLayoutAttributeCenterY
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:_menuView
                                   attribute:NSLayoutAttributeCenterY
                                   multiplier:1.0
                                   constant:0.f];
}

#pragma mark - Helper
//moved
+(UIImage *)blurScreen:(UIViewController *)vc{
    UIImage * imageFromCurrentView = [STMenuController snapshotForViewController:vc];
    return [imageFromCurrentView applyDarkEffect];
}
//moved
+ (UIImage *)snapshotForViewController:(UIViewController *)vc{
    UIGraphicsBeginImageContextWithOptions(vc.view.bounds.size, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [vc.view.layer renderInContext:context];
    UIImage *imageFromCurrentView = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageFromCurrentView;
}
@end

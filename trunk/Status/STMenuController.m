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
#import "STTutorialViewController.h"
#import "STInviteController.h"
#import "STUserProfileViewController.h"
#import "STFacebookLoginController.h"
#import "STInviteFriendsViewController.h"
#import "STFlowTemplateViewController.h"
#import "STLocationManager.h"
#import "STNearbyController.h"
#import "STNotificationsViewController.h"

#import "AppDelegate.h"

@interface STMenuController()<STTutorialDelegate>

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
            _menuView.notificationBadge.layer.cornerRadius = 7.f;
            
        }

    }
    
    return self;
}

- (void)showMenuForController:(UIViewController *)parrentVC{
    
    _currentVC = parrentVC;
    
    _menuView.alpha = 0.f;
    _menuView.blurBackground.image = [self blurCurrentScreen];
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSInteger notifNumber = app.badgeNumber;
    if (notifNumber > 0) {
        _menuView.notificationBadge.text = [NSString stringWithFormat:@" %zd ", notifNumber];
        _menuView.notificationBadge.hidden = NO;
    }
    else{
        _menuView.notificationBadge.hidden = YES;
    }

    [parrentVC.view addSubview:_menuView];
    
    [self addContraintForMenu];
    
    [UIView animateWithDuration:0.33 animations:^{
        _menuView.alpha = 1.f;
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
- (void)goHome{
    [self hideMenu];
    [_currentVC.navigationController popToRootViewControllerAnimated:YES];
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
    STTutorialViewController * tutorialVC = [STTutorialViewController newInstance];
    tutorialVC.delegate = self;
    tutorialVC.backgroundImageForLastElement = [STMenuController snapshotForViewController:_currentVC];
    tutorialVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [_currentVC presentViewController:tutorialVC animated:YES completion:nil];
}
- (void)goMyProfile{
    [self resetNavigationControllerStack];
    [self hideMenu];
    STUserProfileViewController * userProfileVC = [STUserProfileViewController newControllerWithUserId:[STFacebookLoginController sharedInstance].currentUserId];
    userProfileVC.isMyProfile = YES;
    [_currentVC.navigationController pushViewController:userProfileVC animated:YES];

}
- (void)goFriendsInviter {
    [self resetNavigationControllerStack];
    [self hideMenu];
    STInviteFriendsViewController * inviteFriendsVC = [STInviteFriendsViewController newInstance];
    inviteFriendsVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [_currentVC presentViewController:inviteFriendsVC animated:YES completion:nil];
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


- (STFlowTemplateViewController *)appMainController {
    //TODO: remove this by refactoring image posting - NEEDS TO BE DONE ASAP

    AppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    
    STFlowTemplateViewController * appMainController = (STFlowTemplateViewController *)appDelegate.window.rootViewController;;
    if ([appMainController isKindOfClass:[UINavigationController class]]) {
        appMainController = [(UINavigationController *)_currentVC viewControllers].firstObject;
    }
    
    return appMainController;
}

#pragma mark - STTutorialDelegate

-(void)tutorialDidDissmiss{
    if ([[STInviteController sharedInstance] shouldInviteBeAvailable]) {
        [self goFriendsInviter];
    }
}

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

-(UIImage *)blurCurrentScreen{
    UIImage * imageFromCurrentView = [STMenuController snapshotForViewController:_currentVC];
    return [imageFromCurrentView applyDarkEffect];
}

+ (UIImage *)snapshotForViewController:(UIViewController *)vc{
    UIGraphicsBeginImageContextWithOptions(vc.view.bounds.size, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [vc.view.layer renderInContext:context];
    UIImage *imageFromCurrentView = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageFromCurrentView;
}
@end

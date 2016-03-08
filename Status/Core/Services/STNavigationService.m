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

@interface STNavigationService ()

@end

@implementation STNavigationService
-(instancetype)init{
    self = [super init];
    if (self) {
        
        _imagePickerController = [STImagePickerController new];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLoggedIn) name:kNotificationUserDidLoggedIn object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidRegister) name:kNotificationUserDidRegister object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLoggedOut) name:kNotificationUserDidLoggedOut object:nil];
        
    }
    return self;
}

- (void)userDidLoggedIn{
    [self presentTabBarController];
}

- (void)userDidRegister{
    [self presentTabBarController];
}

- (void)userDidLoggedOut{
    [self presentLoginScreen];
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
    //TODO: dev_1_2 add tab bar here as root
    AppDelegate *appDel=(AppDelegate *)[UIApplication sharedApplication].delegate;
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UINavigationController *navController = [storyboard instantiateInitialViewController];
//    [appDel.window setRootViewController:navController];
    
    STTabBarViewController * tabBar = [STTabBarViewController newController];
    [appDel.window setRootViewController:tabBar];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

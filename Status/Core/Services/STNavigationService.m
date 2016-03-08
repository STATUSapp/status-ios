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

@interface STNavigationService ()

@property (nonatomic, strong) STImagePickerController *imagePickerController;

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
    [STNavigationService presentTabBarController];
}

- (void)userDidRegister{
    [STNavigationService presentTabBarController];
}

- (void)userDidLoggedOut{
    [STNavigationService presentLoginScreen];
}

+ (void)presentLoginScreen{
    AppDelegate *appDel=(AppDelegate *)[UIApplication sharedApplication].delegate;
    if ([appDel.window.rootViewController isKindOfClass:[STLoginViewController class]]) {
        return;
    }

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LoginScene" bundle:nil];
    STLoginViewController *viewController = (STLoginViewController *) [storyboard instantiateViewControllerWithIdentifier:@"loginScreen"];
    [appDel.window setRootViewController:viewController];

}

+ (void)presentTabBarController{
    NSLog(@"Tabbar Controller presented");
    //TODO: dev_1_2 add tab bar here as root
    AppDelegate *appDel=(AppDelegate *)[UIApplication sharedApplication].delegate;
    UINavigationController *navController = [FeedCVC mainFeedController];
    [appDel.window setRootViewController:navController];
}

+(STImagePickerController *)imagePickerController{
    return [[CoreManager navigationService] imagePickerController];
}

@end

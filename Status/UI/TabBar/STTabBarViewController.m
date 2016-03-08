//
//  STTabBarViewController.m
//  Status
//
//  Created by Silviu Burlacu on 28/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STTabBarViewController.h"
#import "STFlowTemplateViewController.h"
#import "STSettingsViewController.h"
#import "STTakeAPhotoViewController.h"

static NSString * storyboardIdentifier = @"tabBarController";

@interface STTabBarViewController ()

@end

@implementation STTabBarViewController

+ (instancetype)newController {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    STTabBarViewController * vc = [storyboard instantiateViewControllerWithIdentifier:storyboardIdentifier];
    [vc setupTabBar];
    return vc;
}

#pragma mark - Lifecycle

- (void)setupTabBar {
    
    // add home flow
    
    UIViewController * homeVc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    homeVc.title = @"Home";
    
    // add explore flow
    
    // add take a photo
    
    STTakeAPhotoViewController * takeAPhotoVC = [STTakeAPhotoViewController newController];
    takeAPhotoVC.title = @"Take a Photo";
    
    // add message / notifications
    
    // add my profile
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    STSettingsViewController * settingsCtrl = [storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([STSettingsViewController class])];
    UINavigationController   * settingsNav = [[UINavigationController alloc] initWithRootViewController:settingsCtrl];
    settingsNav.navigationBarHidden = YES;
    settingsNav.title = @"Settings";


    [self setViewControllers:@[homeVc, takeAPhotoVC, settingsNav] animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



@end

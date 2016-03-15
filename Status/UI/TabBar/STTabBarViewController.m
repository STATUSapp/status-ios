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
#import "STNotificationAndChatContainerViewController.h"

#import "FeedCVC.h"

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
    //TODO: dev_1_2 use the storyboard to load navCtrl
    FeedCVC *homeVc = [FeedCVC mainFeedController];
    homeVc.title = NSLocalizedString(@"Home", nil);
    UINavigationController *homeNavCtrl = [[UINavigationController alloc] initWithRootViewController:homeVc];
    
    homeNavCtrl.navigationBarHidden = YES;

    // add explore flow
    
    // add take a photo
    
    STTakeAPhotoViewController * takeAPhotoVC = [STTakeAPhotoViewController newController];
    takeAPhotoVC.title = @"Take a Photo";
    UINavigationController * takePhotoNav = [[UINavigationController alloc] initWithRootViewController:takeAPhotoVC];
    takePhotoNav.title = @"Take a Photo";
    takePhotoNav.navigationBarHidden = YES;
    // add message / notifications
    
    STNotificationAndChatContainerViewController * notifAndChatVC = [STNotificationAndChatContainerViewController newController];
    UINavigationController * notifChatNav = [[UINavigationController alloc] initWithRootViewController:notifAndChatVC];
    notifChatNav.title = @"Notifications and Messages";
    notifChatNav.navigationBarHidden = YES;
    
    // add my profile
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    STSettingsViewController * settingsCtrl = [storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([STSettingsViewController class])];
    UINavigationController   * settingsNav = [[UINavigationController alloc] initWithRootViewController:settingsCtrl];
    settingsNav.navigationBarHidden = YES;
    settingsNav.title = @"Settings";
    
    [self setViewControllers:@[homeNavCtrl, takePhotoNav, notifChatNav, settingsNav] animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



@end

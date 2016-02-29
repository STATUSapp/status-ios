//
//  LoginViewController.m
//  Status
//
//  Created by Andrus Cosmin on 17/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STLoginViewController.h"
#import "STImageCacheController.h"
#import "STConstants.h"
#import "STFacebookLoginController.h"
#import "STNetworkQueueManager.h"
#import <FBSDKLoginKit.h>

@interface STLoginViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *splashBackground;
@end

@implementation STLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _splashBackground.image = [STUIHelper splashImageWithLogo:NO];
    [STFacebookLoginController sharedInstance].loginButton.hidden = NO;
    FBSDKLoginButton *loginBtn = [STFacebookLoginController sharedInstance].loginButton;
    loginBtn.hidden = NO;
    CGRect frame = loginBtn.frame;
    frame.origin.y = 0;
    loginBtn.frame = frame;
    [self.view addSubview:loginBtn];
    NSLayoutConstraint *bottomConstraint =[NSLayoutConstraint
                                           constraintWithItem:loginBtn
                                           attribute:NSLayoutAttributeBottom
                                           relatedBy:NSLayoutRelationEqual
                                           toItem:self.view
                                           attribute:NSLayoutAttributeBottom
                                           multiplier:1.f
                                           constant:-65];
    NSLayoutConstraint *centerConstraint = [NSLayoutConstraint constraintWithItem:loginBtn
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1.f
                                                                         constant:1.f];
    
    NSLayoutConstraint *widthContraint = [NSLayoutConstraint constraintWithItem:loginBtn
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.f
                                                                         constant:SCREEN_WIDTH - 100.f];
    
    NSLayoutConstraint *heightContraint = [NSLayoutConstraint constraintWithItem:loginBtn
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1.f
                                                                       constant:44.f];


    
    
     [self.view addConstraints:@[bottomConstraint, centerConstraint, widthContraint, heightContraint]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

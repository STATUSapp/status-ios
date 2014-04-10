//
//  LoginViewController.m
//  Status
//
//  Created by Andrus Cosmin on 17/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STLoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "STImageCacheController.h"
#import "STWebServiceController.h"
#import "STConstants.h"
#import "STFacebookController.h"

@interface STLoginViewController ()
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
    [STWebServiceController sharedInstance].isPerformLoginOrRegistration = FALSE;
    FBLoginView *loginBtn = [STFacebookController sharedInstance].loginButton;
    [self.view addSubview:loginBtn];
    NSLayoutConstraint *bottomConstraint =[NSLayoutConstraint
                                           constraintWithItem:loginBtn
                                           attribute:NSLayoutAttributeBottom
                                           relatedBy:NSLayoutRelationEqual
                                           toItem:self.view
                                           attribute:NSLayoutAttributeBottom
                                           multiplier:1.f
                                           constant:-102];
    
     [self.view addConstraints:@[bottomConstraint]];
    
    FBLoginView *loginBtn2 = [STFacebookController sharedInstance].loginButton2;
    [self.view addSubview:loginBtn2];
    NSLayoutConstraint *bottomConstraint2 =[NSLayoutConstraint
                                           constraintWithItem:loginBtn2
                                           attribute:NSLayoutAttributeBottom
                                           relatedBy:NSLayoutRelationEqual
                                           toItem:self.view
                                           attribute:NSLayoutAttributeBottom
                                           multiplier:1.f
                                           constant:-55];
    
    [self.view addConstraints:@[bottomConstraint2]];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

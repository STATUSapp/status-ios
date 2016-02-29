//
//  TestViewController.m
//  Status
//
//  Created by Andrus Cosmin on 29/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "TestViewController.h"
#import "FBSDKLoginButton.h"
#import "STFacebookLoginController.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    FBSDKLoginButton *lgBtn = [[CoreManager loginService] facebookLoginButton];
    
    [lgBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    lgBtn.hidden = NO;
    CGRect frame = lgBtn.frame;
    frame.origin.y = 0;
    lgBtn.frame = frame;
    [self.view addSubview:lgBtn];
    NSLayoutConstraint *bottomConstraint =[NSLayoutConstraint
                                           constraintWithItem:lgBtn
                                           attribute:NSLayoutAttributeBottom
                                           relatedBy:NSLayoutRelationEqual
                                           toItem:self.view
                                           attribute:NSLayoutAttributeBottom
                                           multiplier:1.f
                                           constant:-65];
    NSLayoutConstraint *centerConstraint = [NSLayoutConstraint constraintWithItem:lgBtn
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1.f
                                                                         constant:1.f];
    
    NSLayoutConstraint *widthContraint = [NSLayoutConstraint constraintWithItem:lgBtn
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1.f
                                                                       constant:SCREEN_WIDTH - 100.f];
    
    NSLayoutConstraint *heightContraint = [NSLayoutConstraint constraintWithItem:lgBtn
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.f
                                                                        constant:44.f];
    
    
    
    
    [self.view addConstraints:@[bottomConstraint, centerConstraint, widthContraint, heightContraint]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

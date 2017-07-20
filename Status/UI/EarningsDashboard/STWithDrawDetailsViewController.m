//
//  STWithDrawDetailsViewController.m
//  Status
//
//  Created by Cosmin Andrus on 12/07/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STWithDrawDetailsViewController.h"
#import "STWithdrawDetailsCVC.h"
#import "STWithdrawDetailsObj.h"
#import "STTabBarViewController.h"

@interface STWithDrawDetailsViewController ()<STWithdrawDetailsChildCVCProtocol>

@property (nonatomic, strong) STWithdrawDetailsCVC *childVC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveButtonHeightConstr;

@end

@implementation STWithDrawDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _saveButtonHeightConstr.constant = 0.f;
    [self.view layoutIfNeeded];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [(STTabBarViewController *)self.tabBarController setTabBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [(STTabBarViewController *)self.tabBarController setTabBarHidden:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    _childVC = segue.destinationViewController;
    _childVC.delegate = self;
}

#pragma mark - IBActions

- (IBAction)onBackButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onSaveButtonPressed:(id)sender {
    [_childVC save];
}

#pragma mark - STWithdrawDetailsChildCVCProtocol

-(void)childCVCHasChanges:(BOOL)hasChanges{
    _saveButtonHeightConstr.constant = hasChanges? 48.f:0.f;
    [self.view layoutIfNeeded];
}
@end

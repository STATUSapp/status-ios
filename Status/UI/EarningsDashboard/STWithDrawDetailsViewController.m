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

@interface STWithDrawDetailsViewController ()

@property (nonatomic, strong) STWithdrawDetailsCVC *childVC;

@end

@implementation STWithDrawDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
}

#pragma mark - IBActions

- (IBAction)onBackButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onSaveButtonPressed:(id)sender {
    [_childVC save];
}

@end

//
//  STFacebookInviterViewController.m
//  Status
//
//  Created by Silviu Burlacu on 21/10/15.
//  Copyright © 2015 Andrus Cosmin. All rights reserved.
//

#import "STFacebookInviterViewController.h"
#import "STFacebookHelper.h"

@interface STFacebookInviterViewController ()
@property (nonatomic, strong) STFacebookHelper * facebookHelper;
@end

@implementation STFacebookInviterViewController


+ (STFacebookInviterViewController *)newController {
    UIStoryboard * inviter = [UIStoryboard storyboardWithName:@"Invite" bundle:[NSBundle mainBundle]];
    return [inviter instantiateViewControllerWithIdentifier:@"STFacebookInviterViewController"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)inviteFacebookFriends:(id)sender {
    _facebookHelper = [STFacebookHelper new];
    [_facebookHelper promoteTheApp];
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

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

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *inviteCollection;

@end

@implementation STFacebookInviterViewController


+ (STFacebookInviterViewController *)newController {
    UIStoryboard * inviter = [UIStoryboard storyboardWithName:@"Invite" bundle:[NSBundle mainBundle]];
    return [inviter instantiateViewControllerWithIdentifier:@"STFacebookInviterViewController"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer * tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inviteFacebookFriends:)];
    UITapGestureRecognizer * tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inviteFacebookFriends:)];
    UITapGestureRecognizer * tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inviteFacebookFriends:)];
    
    NSArray * taps = @[tap1, tap2, tap3];
    
    for (int i = 0; i < 3; i++) {
        [[_inviteCollection objectAtIndex:i] addGestureRecognizer:[taps objectAtIndex:i]];
    }
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

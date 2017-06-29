//
//  STEditProfileViewController.m
//  Status
//
//  Created by Silviu Burlacu on 03/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STEditProfileViewController.h"
#import "STUpdateUserProfileRequest.h"
#import "STUserProfilePool.h"
#import "STEditProfileTVC.h"

const NSInteger kMaxNumberOfCharacters = 150;
const NSInteger kDefaultValueForTopConstraint = 26;

@interface STEditProfileViewController ()
//@property (weak, nonatomic) IBOutlet UILabel *counterLabel;
@property (nonatomic, strong) STUserProfile *formUserProfile;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@end

@implementation STEditProfileViewController

+ (STEditProfileViewController *)newController {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"UserProfile" bundle:[NSBundle mainBundle]];
    STEditProfileViewController * newController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([STEditProfileViewController class])];
    return newController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onTapClose:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onTapSave:(id)sender {
    __weak STEditProfileViewController * weakSelf = self;
    [STUpdateUserProfileRequest updateUserProfileWithProfile:_formUserProfile
                                              withCompletion:^(id response, NSError *error) {
                                                  
                                                  if (!error) {
                                                      [[CoreManager profilePool] addProfiles:@[weakSelf.formUserProfile]];
                                                      UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Update Profile" message:@"Success!" preferredStyle:UIAlertControllerStyleAlert];
                                                      
                                                      [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                                                      
                                                      [weakSelf.navigationController popViewControllerAnimated:YES];
                                                      
                                                      [weakSelf.navigationController presentViewController:alert animated:YES completion:nil];
                                                  }
                                                  else
                                                  {
                                                      NSLog(@"%@", error.debugDescription);
                                                      [weakSelf showProfileErrorAlert];
                                                  }
                                                  
                                              }
                                                     failure:^(NSError *error) {
                                                         NSLog(@"%@", error.debugDescription);
                                                         [weakSelf showProfileErrorAlert];
                                                         
                                                     }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"USER_PROFILE_TVC"]) {
        STEditProfileTVC *vc = segue.destinationViewController;
        if (!_formUserProfile) {
            _formUserProfile = [STUserProfile userProfileWithDict:_userProfile.infoDict];
        }
        vc.userProfile = _formUserProfile;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


- (void)showProfileErrorAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:@"Your profile could not be updated at this time. Please try again later."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end

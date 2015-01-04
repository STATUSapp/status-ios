//
//  STEditProfileViewController.m
//  Status
//
//  Created by Silviu Burlacu on 03/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STEditProfileViewController.h"
#import "STUpdateUserProfileRequest.h"
#import "STUserProfileViewController.h"

@interface STEditProfileViewController () <UITextFieldDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtFieldName;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldLocation;
@property (weak, nonatomic) IBOutlet UITextView *txtViewBio;
@property (nonatomic, strong) NSString * userId;
@end

@implementation STEditProfileViewController

+ (STEditProfileViewController *)newControllerWithUserId:(NSString *)userId {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"UserProfile" bundle:[NSBundle mainBundle]];
    STEditProfileViewController * newController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([STEditProfileViewController class])];
    newController.userId = userId;
    return newController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self setupVisualsWithDictionary:_userProfileDict];
    
}

- (void)setupVisualsWithDictionary:(NSDictionary *)dict {
    _txtFieldLocation.text = [STUserProfileViewController getObjectFromUserProfileDict:dict forKey:kLocationKey];
    _txtViewBio.text = [STUserProfileViewController getObjectFromUserProfileDict:dict forKey:kBioKey];
    _txtFieldName.text = [STUserProfileViewController getObjectFromUserProfileDict:dict forKey:kFulNameKey];
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
    [STUpdateUserProfileRequest updateUserProfileWithFirstName:nil
                                                      lastName:nil
                                                      fullName:_txtFieldName.text
                                                  homeLocation: _txtFieldLocation.text
                                                           bio:_txtViewBio.text
                                                withCompletion:^(id response, NSError *error) {
                                                    
                                                    [[[UIAlertView alloc] initWithTitle:@"Update Profile" message:@"Succes!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                                                    
                                                    [weakSelf.navigationController popViewControllerAnimated:YES];
                                                }
                                                       failure:^(NSError *error) {
                                                           NSLog(@"%@", error.debugDescription);
        
                                                }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _txtFieldLocation) {
        [_txtViewBio becomeFirstResponder];
    }
    if (textField == _txtFieldName) {
        [_txtFieldLocation becomeFirstResponder];
    }
    return YES;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text  isEqualToString: @"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

@end

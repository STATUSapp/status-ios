//
//  STEditProfileViewController.m
//  Status
//
//  Created by Silviu Burlacu on 03/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STEditProfileViewController.h"
#import "STUpdateUserProfileRequest.h"
#import "STImageCacheController.h"
#import "STUploadNewProfilePictureRequest.h"
#import "STUserProfilePool.h"

const NSInteger kMaxNumberOfCharacters = 150;
const NSInteger kDefaultValueForTopConstraint = 26;

@interface STEditProfileViewController () <UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtFieldName;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldLocation;
@property (weak, nonatomic) IBOutlet UITextView *txtViewBio;
@property (nonatomic, strong) NSString * userId;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrProfileTop;
@property (weak, nonatomic) IBOutlet UILabel *counterLabel;
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

    [self setupVisualsWithUserProfile:_userProfile];
    
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
}

- (void)setupVisualsWithUserProfile:(STUserProfile *)profile {
    _txtFieldLocation.text = profile.homeLocation;
    _txtViewBio.text = profile.bio;
    _txtFieldName.text = profile.fullName;
    _counterLabel.text = [NSString stringWithFormat:@"%lu/%ld characters", (unsigned long)[_txtViewBio.text length], (long)kMaxNumberOfCharacters];
    __weak STEditProfileViewController *weakSelf = self;
    [[CoreManager imageCacheService] loadImageWithName:profile.mainImageUrl andCompletion:^(UIImage *img) {
        weakSelf.profileImage.image = img;
    }];
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
                                                    
                                                    if (!error) {
                                                        weakSelf.userProfile.fullName = _txtFieldName.text;
                                                        weakSelf.userProfile.homeLocation = _txtFieldLocation.text;
                                                        weakSelf.userProfile.bio = _txtViewBio.text;
                                                        
                                                        [[CoreManager profilePool] addProfiles:@[weakSelf.userProfile]];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - iPhone 4 or less handle texts and keyboards

- (void)handleKeyboardForTextInputObject:(id)textInputObject {
    if (IS_IPHONE_4_OR_LESS) {
        
        [UIView animateWithDuration:0.3 animations:^{
            if(textInputObject == _txtFieldLocation) {
                _constrProfileTop.constant = - 24;
            } else if(textInputObject == _txtFieldName) {
                _constrProfileTop.constant = - 24;
            } else if(textInputObject == _txtViewBio) {
                _constrProfileTop.constant = - 65;
            }
            
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
            
        }];
    }
}

- (void)resetViewAfterKeyboardDidHide {
    
    if (IS_IPHONE_4_OR_LESS) {
        
        [UIView animateWithDuration:0.3 animations:^{
            _constrProfileTop.constant = kDefaultValueForTopConstraint;
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        }];
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self handleKeyboardForTextInputObject:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self resetViewAfterKeyboardDidHide];
}

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

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self handleKeyboardForTextInputObject:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self resetViewAfterKeyboardDidHide];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text  isEqualToString: @"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    if (textView.text.length + text.length > kMaxNumberOfCharacters) {
        return NO;
    }

    return YES;
}

-(void)textViewDidChange:(UITextView *)textView{
    _counterLabel.text = [NSString stringWithFormat:@"%lu/%ld characters", (unsigned long)[_txtViewBio.text length], (long)kMaxNumberOfCharacters];
}
#pragma mark - IBAction

- (IBAction)onChangeProfileImagePressed:(id)sender {
    __weak STEditProfileViewController *weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Photos"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                            handler:nil]];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"Take a Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf presentImagePickerForType:UIImagePickerControllerSourceTypeCamera];
        }]];

    }
    [alert addAction:[UIAlertAction actionWithTitle:@"Open Camera Roll" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf presentImagePickerForType:UIImagePickerControllerSourceTypePhotoLibrary|UIImagePickerControllerSourceTypeSavedPhotosAlbum];

    }]];
    
    [self presentViewController:alert
                       animated:YES
                     completion:nil];
}

-(void)presentImagePickerForType:(UIImagePickerControllerSourceType)type{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = type;
    [imagePicker setAllowsEditing:YES];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)showPhotoErrorAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:@"Your photo could not be updated at this time. Please try again later."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showProfileErrorAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:@"Your profile could not be updated at this time. Please try again later."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    __weak STEditProfileViewController *weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
        
        NSData *imageData = UIImageJPEGRepresentation(img, 1.f);
        [STUploadNewProfilePictureRequest uploadProfilePicture:imageData withCompletion:^(id response, NSError *error) {
            if ([response[@"status_code"] integerValue] == STWebservicesSuccesCod) {
                weakSelf.userProfile.mainImageUrl = [response[@"user_photo"] stringByReplacingHttpWithHttps];
                [[CoreManager profilePool] addProfiles:@[weakSelf.userProfile]];
                [[CoreManager imageCacheService] loadImageWithName:response[@"user_photo"] andCompletion:^(UIImage *img) {
                    weakSelf.profileImage.image = img;
                }];
            }
            else
            {
                NSLog(@"Response: %@", response);
                [self showPhotoErrorAlert];
            }
        } failure:^(NSError *error) {
            NSLog(@"Error uploading new profile photo: %@", error.description);
            [self showPhotoErrorAlert];

        }];
    }];

}

@end

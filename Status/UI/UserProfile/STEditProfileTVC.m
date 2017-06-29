//
//  SEditProfileTVC.m
//  Status
//
//  Created by Cosmin Andrus on 28/06/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STEditProfileTVC.h"
#import "STImageCacheController.h"
#import "STUploadNewProfilePictureRequest.h"
#import "STUserProfilePool.h"

@interface STEditProfileTVC ()<UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *txtFieldName;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldUserName;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldGender;
@property (weak, nonatomic) IBOutlet UITextView *txtViewBio;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (nonatomic, strong) NSArray *textFieldsOrder;
@property (nonatomic, strong) NSArray *genderDatasourceArray;

@end

@implementation STEditProfileTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _textFieldsOrder = @[_txtFieldName, _txtFieldUserName, _txtFieldGender, _txtViewBio];
    _txtFieldGender.inputView = _pickerView;
    _genderDatasourceArray = @[NSLocalizedString(@"Male", nil),
                               NSLocalizedString(@"Female", nil),
                               NSLocalizedString(@"Other", nil)];
    [self setupVisualsWithUserProfile:_userProfile];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)setupVisualsWithUserProfile:(STUserProfile *)profile {
    _txtFieldUserName.text = profile.username;
    _txtViewBio.text = profile.bio;
    _txtFieldName.text = profile.fullName;
    _txtFieldGender.text = [profile genderString];
//    _counterLabel.text = [NSString stringWithFormat:@"%lu/%ld characters", (unsigned long)[_txtViewBio.text length], (long)kMaxNumberOfCharacters];
    __weak STEditProfileTVC *weakSelf = self;
    [[CoreManager imageCacheService] loadImageWithName:profile.mainImageUrl andCompletion:^(UIImage *img) {
        if (img) {
            weakSelf.profileImage.image = img;
        }
        else
            weakSelf.profileImage.image = [UIImage imageNamed:@"Mask"];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == _txtFieldGender) {
        [_pickerView selectRow:[self pickerRowForUserGender:_userProfile.profileGender] inComponent:0 animated:YES];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == _txtFieldName) {
        _userProfile.fullName = textField.text;
    }
    else if (textField == _txtFieldUserName){
        _userProfile.username = textField.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSInteger indexOfTextInput = [_textFieldsOrder indexOfObject:textField];
    if (indexOfTextInput == [_textFieldsOrder count] - 1) {
        [textField resignFirstResponder];
    }
    else
    {
        id nextTextInput = [_textFieldsOrder objectAtIndex:indexOfTextInput + 1];
        [nextTextInput becomeFirstResponder];
    }
    return YES;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView == _txtViewBio) {
        _userProfile.bio = textView.text;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text  isEqualToString: @"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}


#pragma mark - IBAction

- (IBAction)onChangeProfileImagePressed:(id)sender {
    __weak STEditProfileTVC *weakSelf = self;
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
    
    [self.parentViewController presentViewController:alert
                                            animated:YES
                                          completion:nil];
}

-(void)presentImagePickerForType:(UIImagePickerControllerSourceType)type{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = type;
    [imagePicker setAllowsEditing:YES];
    [self.parentViewController presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    __weak STEditProfileTVC *weakSelf = self;
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

- (void)showPhotoErrorAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:@"Your photo could not be updated at this time. Please try again later."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UIPickerView Delegate

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [_genderDatasourceArray count];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [_genderDatasourceArray objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    _userProfile.gender = [_genderDatasourceArray[row] lowercaseString];
    _userProfile.profileGender = [_userProfile genderFromString:_userProfile.gender];
    _txtFieldGender.text = [_userProfile genderString];
}

- (STProfileGender)genderFromPickerIndex:(NSInteger)row{
    if (row == 0) {
        return STProfileGenderMale;
    }
    if (row == 1) {
        return STProfileGenderFemale;
    }
    return STProfileGenderOther;
}

- (NSInteger)pickerRowForUserGender:(STProfileGender)gender{
    if (gender == STProfileGenderMale) {
        return 0;
    }
    if (gender == STProfileGenderFemale) {
        return 1;
    }
    return 2;
}

@end

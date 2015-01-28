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
#import "STImageCacheController.h"
#import "STUploadNewProfilePictureRequest.h"

const NSInteger kMaxNumberOfCharacters = 150;

@interface STEditProfileViewController () <UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtFieldName;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldLocation;
@property (weak, nonatomic) IBOutlet UITextView *txtViewBio;
@property (nonatomic, strong) NSString * userId;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
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

    [self setupVisualsWithDictionary:_userProfileDict];
    
}

- (void)setupVisualsWithDictionary:(NSDictionary *)dict {
    _txtFieldLocation.text = [STUserProfileViewController getObjectFromUserProfileDict:dict forKey:kLocationKey];
    _txtViewBio.text = [STUserProfileViewController getObjectFromUserProfileDict:dict forKey:kBioKey];
    _txtFieldName.text = [STUserProfileViewController getObjectFromUserProfileDict:dict forKey:kFulNameKey];
    _counterLabel.text = [NSString stringWithFormat:@"%lu/%ld characters", (unsigned long)[_txtViewBio.text length], (long)kMaxNumberOfCharacters];
    __weak STEditProfileViewController *weakSelf = self;
    [[STImageCacheController sharedInstance] loadImageWithName:dict[@"user_photo"] andCompletion:^(UIImage *img) {
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
    UIActionSheet *actionChoose = [[UIActionSheet alloc] initWithTitle:@"Photos" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Take a Photo",@"Open Camera Roll", nil];
    
    
    [actionChoose showFromRect: ((UIButton *)sender).frame inView:self.view animated:YES];
}

#pragma \mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    @try {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = (buttonIndex==0)?UIImagePickerControllerSourceTypeCamera:UIImagePickerControllerSourceTypePhotoLibrary|UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [imagePicker setAllowsEditing:YES];
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device has no camera." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)showErrorAlert {
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Your photo could not be updated at this time. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    __weak STEditProfileViewController *weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
        
        //TODO: move this on save button pressed?
        NSData *imageData = UIImageJPEGRepresentation(img, 1.f);
        [STUploadNewProfilePictureRequest uploadProfilePicture:imageData withCompletion:^(id response, NSError *error) {
            if ([response[@"status_code"] integerValue] == STWebservicesSuccesCod) {
                [[STImageCacheController sharedInstance] loadImageWithName:response[@"user_photo"] andCompletion:^(UIImage *img) {
                    weakSelf.profileImage.image = img;
                }];
            }
            else
            {
                NSLog(@"Response: %@", response);
                [self showErrorAlert];
            }
        } failure:^(NSError *error) {
            NSLog(@"Error uploading new profile photo: %@", error.description);
            [self showErrorAlert];

        }];
    }];

}

@end

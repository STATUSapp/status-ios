//
//  SEditProfileTVC.m
//  Status
//
//  Created by Cosmin Andrus on 28/06/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STEditProfileTVC.h"
#import "STUploadNewProfilePictureRequest.h"
#import "STUserProfilePool.h"
#import "UIImageView+Mask.h"
#import "SDWebImageManager.h"

@interface STEditProfileTVC ()<UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *txtFieldName;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldUserName;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldGender;
@property (weak, nonatomic) IBOutlet UITextView *txtViewBio;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (nonatomic, strong) NSArray *textFieldsOrder;
@property (nonatomic, strong) NSArray *genderDatasourceArray;

@property (nonatomic, assign) BOOL imagePickerPresented;
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
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 48.f;
}

- (void)setupVisualsWithUserProfile:(STUserProfile *)profile {
    _txtFieldUserName.text = profile.username;
    _txtViewBio.text = profile.bio;
    _txtFieldName.text = profile.fullName;
    _txtFieldGender.text = [profile genderString];
//    _counterLabel.text = [NSString stringWithFormat:@"%lu/%ld characters", (unsigned long)[_txtViewBio.text length], (long)kMaxNumberOfCharacters];
    __weak STEditProfileTVC *weakSelf = self;
    SDWebImageManager *sdManager = [SDWebImageManager sharedManager];
    [sdManager loadImageWithURL:[NSURL URLWithString:profile.mainImageUrl]
                        options:SDWebImageHighPriority
                       progress:nil
                      completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                          __strong STEditProfileTVC *strongSelf = weakSelf;
                          if (error!=nil) {
                              NSLog(@"Error downloading image: %@", error.debugDescription);
                              [strongSelf.profileImage maskImage:[UIImage imageNamed:@"Mask"]];
                          }
                          else if(finished){
                              UIImage *newImg = image;
                              [strongSelf.profileImage maskImage:newImg];
                          }else{
                              [strongSelf.profileImage maskImage:[UIImage imageNamed:@"Mask"]];
                          }
                      }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1 &&
        indexPath.row == 3) {
//        UITableViewCell *cell = [super tableView:self.tableView
//                           cellForRowAtIndexPath:indexPath];
//        NSLog(@"Cell : %@", NSStringFromCGSize([_txtViewBio contentSize]));
        return [_txtViewBio contentSize].height;
    }
    
    return [super tableView:self.tableView
   heightForRowAtIndexPath:indexPath];
}

- (BOOL)resignCurrentField{
    //validations
    NSString *errorMessage;
    if ([_txtFieldName.text length] == 0) {
        errorMessage = NSLocalizedString(@"Full Name cannot be empty.", nil);
    }
 
    if ([_txtFieldUserName.text length] == 0) {
        errorMessage = NSLocalizedString(@"Username cannot be empty.", nil);
    }

    if (errorMessage) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self.parentViewController presentViewController:alert animated:YES completion:nil];
        return NO;
    }

    _userProfile.fullName = _txtFieldName.text;
    _userProfile.username = _txtFieldUserName.text;
    _userProfile.bio = _txtViewBio.text;
    
    [self.view endEditing:YES];
    
    return YES;
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

-(void)textViewDidChange:(UITextView *)textView{
    [UIView setAnimationsEnabled:NO];
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [UIView setAnimationsEnabled:YES];
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
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Photos"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                            handler:nil]];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"Take a Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self presentImagePickerForType:UIImagePickerControllerSourceTypeCamera];
        }]];
        
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"Open Camera Roll" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self presentImagePickerForType:UIImagePickerControllerSourceTypePhotoLibrary|UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        
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
    [self.parentViewController presentViewController:imagePicker animated:YES completion:^{
        self.imagePickerPresented = YES;
    }];
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{

    [picker dismissViewControllerAnimated:YES completion:^{
        __weak STEditProfileTVC *weakSelf = self;
        self.imagePickerPresented = NO;
        UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
        [self.profileImage maskImage:img];
        NSData *imageData = UIImageJPEGRepresentation(img, 1.f);
        [STUploadNewProfilePictureRequest uploadProfilePicture:imageData withCompletion:^(id response, NSError *error) {
            __strong STEditProfileTVC *strongSelf = weakSelf;
            if ([response[@"status_code"] integerValue] == STWebservicesSuccesCod) {
                strongSelf.userProfile.mainImageUrl = [response[@"user_photo"] stringByReplacingHttpWithHttps];
                if (strongSelf.userProfile) {
                    [[CoreManager profilePool] addProfiles:@[strongSelf.userProfile]];
                }
            }
            else
            {
                NSLog(@"Response: %@", response);
                [strongSelf showPhotoErrorAlert];
            }
        } failure:^(NSError *error) {
            __strong STEditProfileTVC *strongSelf = weakSelf;
            NSLog(@"Error uploading new profile photo: %@", error.description);
            [strongSelf showPhotoErrorAlert];
            
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

//- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//    if (self.imagePickerPresented== YES && [navigationController.viewControllers count] == 2) {
//        [self addMaskToView:viewController.view];
////        UIImage *circleMaskImage = [self circleMaskImage];
////        CGRect properRect = [self getCenteredFrame];
////        UIImageView *imageView = [[UIImageView alloc] initWithFrame:properRect];
////        [imageView setImage:circleMaskImage];
////        imageView.userInteractionEnabled = NO;
////        imageView.opaque = YES;
////        [[viewController.view.subviews objectAtIndex:1] addSubview:imageView];
////        [[viewController.view.subviews objectAtIndex:1] sendSubviewToBack:imageView];
//    }
//}
//
//-(void)addMaskToView:(UIView *)view{
//    UIColor *circleColor = [UIColor clearColor];
//    UIColor *maskColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
//    CGFloat screenWidth = [self.view bounds].size.width;
//    CGFloat screenHeight = [self.view bounds].size.height;
//    CGRect circleRect = [self getCenteredFrame];
//    CAShapeLayer *circleLayer = [CAShapeLayer layer];
//    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:circleRect];
//    circlePath.usesEvenOddFillRule = YES;
//    circleLayer.path = [circlePath CGPath];
//    circleLayer.fillColor = circleColor.CGColor;
//    CAShapeLayer *sqareLayer = [CAShapeLayer layer];
//    UIBezierPath *squarePath = [UIBezierPath bezierPathWithRoundedRect:circleRect cornerRadius:0];
//    [squarePath appendPath:circlePath];
//    squarePath.usesEvenOddFillRule = YES;
//    sqareLayer.path = [squarePath CGPath];
//    sqareLayer.fillColor = maskColor.CGColor;
//    
//    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, screenWidth, screenHeight) cornerRadius:0];
//    [maskPath appendPath:squarePath];
//    maskPath.usesEvenOddFillRule = YES;
//    CAShapeLayer *maskLayer = [CAShapeLayer layer];
//    maskLayer.path = maskPath.CGPath;
//    maskLayer.fillRule = kCAFillRuleEvenOdd;
//    maskLayer.fillColor = [UIColor clearColor].CGColor;
//    [maskLayer setMasksToBounds:NO];
//    [view.layer addSublayer:maskLayer];
//    
//}
//
//-(CGRect) getCenteredFrame{
//    CGFloat screenHeight = [[UIApplication sharedApplication].keyWindow bounds].size.height;
//    CGFloat screenWidth = [[UIApplication sharedApplication].keyWindow bounds].size.width;
//    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
//    
//    return CGRectMake(0, (screenHeight - screenWidth - statusBarHeight)/2 + statusBarHeight, screenWidth, screenWidth);
//}
//
//- (UIImage *)circleMaskImage{
//    UIColor *circleColor = [UIColor clearColor];
//    UIColor *maskColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
//    CGFloat screenWidth = [self.view bounds].size.width;
//    CGRect rect = CGRectMake(0.0, 0.0, screenWidth, screenWidth);
//    CAShapeLayer *circleLayer = [CAShapeLayer layer];
//    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:rect];
//    circlePath.usesEvenOddFillRule = YES;
//    circleLayer.path = [circlePath CGPath];
//    circleLayer.fillColor = circleColor.CGColor;
//    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:0];
//    [maskPath appendPath:circlePath];
//    maskPath.usesEvenOddFillRule = YES;
//    CAShapeLayer *maskLayer = [CAShapeLayer layer];
//    maskLayer.path = maskPath.CGPath;
//    maskLayer.fillRule = kCAFillRuleEvenOdd;
//    maskLayer.fillColor = maskColor.CGColor;
//    [maskLayer setMasksToBounds:NO];
//    
//    //export uiimage
//    UIGraphicsBeginImageContext(rect.size);
//    [maskLayer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return outputImage;
//
//}

@end

//
//  STImageUploaderService.m
//  Status
//
//  Created by test on 07/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STImagePickerService.h"
#import "UIAlertController+Additions.h"
#import "STFacebookHelper.h"
#import "UIImage+FixedOrientation.h"
#import <FBSDKLoginKit.h>


@interface STImagePickerService ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, copy) imagePickerCompletion completion;
@property (nonatomic, weak) UIViewController * viewController;
@property (nonatomic, strong) FBSDKLoginManager *loginManager;
@end

@implementation STImagePickerService


- (void)takeCameraPictureFromController:(UIViewController *)vc withCompletion:(imagePickerCompletion)completion {
    _completion = completion;
    _viewController = vc;
    
    @try {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [vc presentViewController:imagePicker animated:YES completion:nil];
    }
    @catch (NSException *exception) {
        
        [UIAlertController presentAlertControllerInViewController:vc title:@"Error" message:@"Your device has no camera." andDismissButtonTitle:@"OK"];
        _completion = nil;
        _viewController = nil;
        completion(nil);
    }
    
}
- (void)launchLibraryPickerFromController:(UIViewController *)vc withCompletion:(imagePickerCompletion)completion {
    _completion = completion;
    _viewController = vc;
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary /*| UIImagePickerControllerSourceTypeSavedPhotosAlbum*/;
    [vc presentViewController:imagePicker animated:YES completion:nil];
    
}
- (void)launchFacebookPickerFromController:(UIViewController *)vc {
    
    _viewController = vc;
    if (!_loginManager) {
        _loginManager = [[FBSDKLoginManager alloc] init];
    }
    __weak STImagePickerService * weakSelf = self;
    
    [FBSDKAccessToken refreshCurrentAccessToken:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        __strong STImagePickerService *strongSelf = weakSelf;
        if (error != nil) {
            
            [UIAlertController presentAlertControllerInViewController:vc title:@"Error" message:@"There was a problem with facebook at this time. Please try again later." andDismissButtonTitle:@"OK"];
        }
        else
        {
            if (![[[FBSDKAccessToken currentAccessToken] permissions] containsObject:@"user_photos"]) {
                
                [strongSelf.loginManager logInWithReadPermissions:@[@"user_photos"]
                                    fromViewController:nil
                                               handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                                   if (!error) {
                                                       [strongSelf presentFacebookPickerScene];
                                                   }
                                                   else
                                                   {
                                                                   [UIAlertController presentAlertControllerInViewController:strongSelf.viewController title:@"Error" message:@"There was a problem with facebook at this time. Please try again later." andDismissButtonTitle:@"OK"];
                                                   }
                                                   
                                               }];
                
            }
            else
                [strongSelf presentFacebookPickerScene];
        }
    }];
    
}

#pragma mark - Helpers

- (void)presentFacebookPickerScene {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FacebookPickerScene" bundle:nil];
    UINavigationController *noteNav = [storyboard instantiateViewControllerWithIdentifier:@"FacebookPicker"];
    
    [_viewController presentViewController:noteNav animated:YES completion:nil];
}


#pragma mark - UIImagePickerController delegate methods

- (void)callCompletion:(UIImage *)fixedOrientationImage{
    _viewController = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_completion) {
        _completion(fixedOrientationImage);
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImage *fixedOrientationImage = [img fixOrientation];
        [self callCompletion:fixedOrientationImage];
    }];
    
}

-(void)facebookPickerDidChooseImage:(NSNotification *)notif{
    NSLog(@"self.navigationController.viewControllers =  %@", _viewController.navigationController.presentedViewController);
    if (![_viewController.presentedViewController isBeingDismissed]){
        [_viewController.presentedViewController dismissViewControllerAnimated:YES completion:^{
            UIImage *image = notif.userInfo[kImageKey];
            [self callCompletion:image];
        }];
    }
}

@end

//
//  STImagePickerController.m
//  Status
//
//  Created by Cosmin Andrus on 30/01/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STImagePickerController.h"
#import "STFacebookHelper.h"
#import "UIImage+FixedOrientation.h"
#import <FBSDKLoginKit.h>

@interface STImagePickerController()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, assign) BOOL forOwner;
@end

@implementation STImagePickerController

-(void)startImagePickerInViewController:(UIViewController *)viewController
                         withCompletion:(imagePickerCompletion)completion
                       andAskCompletion:(askUserToUploadCompletion)askUploadCompletion{
    _viewController = viewController;
    _askUploadCompletion = askUploadCompletion;
    _completion = completion;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(facebookPickerDidChooseImage:)
                                                 name:STFacebookPickerNotification
                                               object:nil];

    UIActionSheet *actionChoose;
    
    if (_forOwner) {
        actionChoose = [[UIActionSheet alloc] initWithTitle:@"Photos" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Take a Photo",@"Open Camera Roll",@"Upload from Facebook", nil];
    } else {
        actionChoose = [[UIActionSheet alloc] initWithTitle:@"Photos" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Take a Photo",@"Open Camera Roll",@"Upload from Facebook", @"Ask user to take a photo", nil];
    }
    
    [actionChoose showFromRect: CGRectZero inView:viewController.view animated:YES];
}

-(void)startImagePickerForOwnerInViewController:(UIViewController *)viewController
                                 withCompletion:(imagePickerCompletion)completion{
    _forOwner = YES;
    [self startImagePickerInViewController:viewController
                            withCompletion:completion
                          andAskCompletion:nil];
}

#pragma mark - Helpers

- (void)presentFacebookPickerScene {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FacebookPickerScene" bundle:nil];
    UINavigationController *noteNav = [storyboard instantiateViewControllerWithIdentifier:@"FacebookPicker"];
    
    [_viewController presentViewController:noteNav animated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == 3 && _forOwner){
        _forOwner = NO;
        return;
    }
    if (buttonIndex == 4) {
        _forOwner = NO;
        return;
    }
    
    if (buttonIndex == 3) {
        if (_askUploadCompletion!=nil) {
            _askUploadCompletion();
        }
        return;
    }
    
    
    if (buttonIndex<=1) {
        @try {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.sourceType = (buttonIndex==0)?UIImagePickerControllerSourceTypeCamera:UIImagePickerControllerSourceTypePhotoLibrary|UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            [_viewController presentViewController:imagePicker animated:YES completion:nil];
        }
        @catch (NSException *exception) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device has no camera." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else
    {
        [FBSDKAccessToken refreshCurrentAccessToken:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (error!=nil) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"There was a problem with facebook at this time. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }
            else
            {
                if (![[[FBSDKAccessToken currentAccessToken] permissions] containsObject:@"user_photos"]) {
                    
                    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
                    [loginManager logInWithReadPermissions:@[@"user_photos"]
                                        fromViewController:nil
                                                   handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                        if (!error) {
                            [self presentFacebookPickerScene];
                        }
                        else
                        {
                            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"There was a problem with facebook at this time. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                        }
                        
                    }];
                    
                }
                else
                    [self presentFacebookPickerScene];
            }
        }];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)callCompletion:(UIImage *)fixedOrientationImage shouldBeCompressed:(BOOL) shouldBeCompressed{
    _viewController = nil;
    _forOwner = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_completion) {
        _completion(fixedOrientationImage, shouldBeCompressed);
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImage *fixedOrientationImage = [img fixOrientation];
        [self callCompletion:fixedOrientationImage shouldBeCompressed:YES];
    }];
    
}

-(void)facebookPickerDidChooseImage:(NSNotification *)notif{
    NSLog(@"self.navigationController.viewControllers =  %@", _viewController.navigationController.presentedViewController);
    if (![_viewController.presentedViewController isBeingDismissed])
        [_viewController.presentedViewController dismissViewControllerAnimated:YES completion:^{
            [self callCompletion:(UIImage *)[notif object] shouldBeCompressed:NO];
        }];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}


@end

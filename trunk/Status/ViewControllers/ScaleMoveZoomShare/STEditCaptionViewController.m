//
//  STEditCaptionViewController.m
//  Status
//
//  Created by Cosmin Andrus on 25/01/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STEditCaptionViewController.h"
#import "STUpdatePostCaptionRequest.h"
#import "STImageCacheController.h"
#import "STSharePhotoViewController.h"

@interface STEditCaptionViewController ()<UITextViewDelegate>
{
    NSString *_captionString;
}
@property (weak, nonatomic) IBOutlet UITextView *textViewCaption;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundBlurrImage;
@property (weak, nonatomic) IBOutlet UINavigationBar *transparentNavBar;
@end

@implementation STEditCaptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.transparentNavBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.transparentNavBar.shadowImage = [UIImage new];
    self.transparentNavBar.translucent = YES;
    [self.view bringSubviewToFront:_transparentNavBar];

    _captionString = _postDict[@"caption"];
    
    if (_captionString ==nil || [_captionString isEqual:[NSNull null]])
        _captionString = @"";
    
    _textViewCaption.text = _captionString;
    [_textViewCaption becomeFirstResponder];
    
    if (_postDict!=nil) {
        __weak STEditCaptionViewController *weakSelf = self;
        [[STImageCacheController sharedInstance] loadPostImageWithName:_postDict[@"full_photo_link"] withPostCompletion:nil andBlurCompletion:^(UIImage *bluredImg) {
            if (bluredImg!=nil) {
                weakSelf.backgroundBlurrImage.image=bluredImg;
            }
        }];

    }
    else{
        _backgroundBlurrImage.image = [UIImage imageWithData:_blurredImageData];
    }
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
#pragma mark - UITextViewDelegate

-(void)textViewDidEndEditing:(UITextView *)textView{
    _captionString = textView.text;
}

- (IBAction)onPostButtonPressed:(id)sender {
    [_textViewCaption resignFirstResponder];
    
    if (_postDict!=nil) {
        __block NSString *postId = _postDict[@"post_id"];
        __weak STEditCaptionViewController *weakSelf = self;
        if (postId!=nil) {
            [STUpdatePostCaptionRequest setPostCaption:_captionString
                                             forPostId:postId
                                        withCompletion:^(id response, NSError *error) {
                                            if ([response[@"status_code"] integerValue] == STWebservicesSuccesCod) {
                                                [weakSelf.delegate captionWasEditedForPost:weakSelf.postDict withNewCaption:_captionString];
                                                [weakSelf onBackButtonPressed:nil];
                                            }
                                            else{
                                                [self showErrorAlert];
                                            }
                                        } failure:^(NSError *error) {
                                            NSLog(@"Error: %@", error.debugDescription);
                                            [self showErrorAlert];
                                        }];
            
            
        }

    }
    else
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        STSharePhotoViewController *viewController = (STSharePhotoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"shareScene"];
        viewController.imgData = _imageData;
        viewController.bluredImgData = _blurredImageData;
        viewController.delegate = _postDelegate;
        viewController.captionString = _captionString;
        [self.navigationController pushViewController:viewController animated:YES];

    }
}

-(void)showErrorAlert{
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

- (IBAction)onBackButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end

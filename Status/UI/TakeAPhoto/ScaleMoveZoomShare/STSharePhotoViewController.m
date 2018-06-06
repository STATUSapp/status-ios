//
//  STSharePhotoViewController.m
//  Status
//
//  Created by Andrus Cosmin on 23/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STSharePhotoViewController.h"
#import "STFacebookHelper.h"
#import "STUploadPostRequest.h"

#import "STDataAccessUtils.h"
#import "STPost.h"
#import "STLocalNotificationService.h"
#import "STTabBarViewController.h"

#import "STNavigationService.h"
#import "STSharePhotoTVC.h"
#import "STImageSuggestionsService.h"
#import "STSnackBarService.h"

@interface STSharePhotoViewController (){
}
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (strong, nonatomic) STSharePhotoTVC *childTVC;

@end

@implementation STSharePhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.hidesBarsOnSwipe = NO;
    self.navigationController.navigationBarHidden = NO;
    if (_controllerType == STShareControllerEditInfo) {
        [_shareButton setTitle:NSLocalizedString(@"DONE", nil) forState:UIControlStateNormal];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [(STTabBarViewController *)self.tabBarController setTabBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [(STTabBarViewController *)self.tabBarController setTabBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"embeded_share_tvc"]) {
        _childTVC = segue.destinationViewController;
        _childTVC.imgData = _imgData;
        _childTVC.post = _post;
        _childTVC.controllerType = _controllerType;
    }
}
#pragma mark IBACTIONS

- (void)handleError:(NSError *)error post:(STPost *)post strongSelf:(STSharePhotoViewController *)strongSelf {
    strongSelf.shareButton.enabled = TRUE;
    if (!error) {
        if ([strongSelf.childTVC postShouldBePostedOnFacebook]==YES ) {
            [strongSelf startPostingWithPostId:post.uuid andImageUrl:post.mainImageUrl];
        }else{
            [strongSelf showMessagesAndDismissForPostId:post.uuid];
        }
    }
}

- (IBAction)onClickShare:(id)sender {
    _shareButton.enabled = FALSE;
    __weak STSharePhotoViewController *weakSelf = self;
    NSString *postCaptionString = [_childTVC postCaptionString];
    NSArray *postShopProducts = [_childTVC postShopProducts];
    NSData *postImageData = [_childTVC postImageData];

    [[CoreManager imageSuggestionsService] setSuggestionsCompletionBlock:nil];
    if (_controllerType == STShareControllerAddPost &&
        [[CoreManager imageSuggestionsService] canCommitCurrentPost]) {
        [[CoreManager imageSuggestionsService] commitCurrentPostWithCaption:postCaptionString
                                                                  imageData:postImageData shopProducts:postShopProducts completion:^(NSError *error, NSArray *objects) {
                                                                      __strong STSharePhotoViewController *strongSelf = weakSelf;
                                                                      STPost *post = [objects firstObject];
                                                                      [self handleError:error post:post strongSelf:strongSelf];
        }];
    }else{
        [STDataAccessUtils editPostWithId:_post.uuid
                         withNewImageData:postImageData
                           withNewCaption:postCaptionString
                         withShopProducts:postShopProducts
                           withCompletion:^(NSArray *objects, NSError *error) {
                               __strong STSharePhotoViewController *strongSelf = weakSelf;
                               STPost *post = [objects firstObject];
                               [self handleError:error post:post strongSelf:strongSelf];
                           }];
    }
    if (_controllerType == STShareControllerAddPost ||
        _controllerType == STShareControllerEditInfo) {
        
    }
}

#pragma mark - Helper

- (void)startPostingWithPostId:(NSString *)postId
                   andImageUrl:(NSString *)imageUrl{
    if ([_childTVC postShouldBePostedOnFacebook]) {
        [self postCurrentPhotoToFacebookWithPostId:postId
                                       andImageUrl:imageUrl];
    }
}
- (void)postCurrentPhotoToFacebookWithPostId:(NSString *)postId
                                 andImageUrl:(NSString *)imageUrl{
    [[CoreManager facebookService] shareImageFromLink:imageUrl];
    [self showMessagesAndDismissForPostId:postId];
}

- (void)showMessagesAndDismissForPostId:(NSString *)postId {
    if (_controllerType == STShareControllerEditInfo) {
        [[CoreManager localNotificationService] postNotificationName:STPostImageWasEdited object:nil userInfo:@{kPostIdKey:postId}];
        [self.navigationController popToRootViewControllerAnimated:YES];
        [[CoreManager navigationService] dismissChoosePhotoVC];
    }else{
        [[CoreManager snackBarService] showSnackBarWithMessage:@"Your photo was posted on STATUS."];
        [self.navigationController popToRootViewControllerAnimated:YES];
        [[CoreManager navigationService] dismissChoosePhotoVC];
        [[CoreManager localNotificationService] postNotificationName:STPostNewImageUploaded object:nil userInfo:@{kPostIdKey:postId}];
    }
}

-(void)showErrorAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Something went wrong. Please try again later." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

@end

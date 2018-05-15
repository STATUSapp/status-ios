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

@interface STSharePhotoViewController (){
}
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (assign, nonatomic)BOOL donePostingToFacebook;

@property (strong, nonatomic)NSError *fbError;

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

- (IBAction)onClickShare:(id)sender {
    _shareButton.enabled = FALSE;
    __weak STSharePhotoViewController *weakSelf = self;
    if (_controllerType == STShareControllerAddPost ||
        _controllerType == STShareControllerEditInfo) {
        
        NSData *postImageData = [_childTVC postImageData];
        NSString *postCaptionString = [_childTVC postCaptionString];
        NSArray *postShopProducts = [_childTVC postShopProducts];
        BOOL postShouldBePostedOnFacebook = [_childTVC postShouldBePostedOnFacebook];
        
        [STDataAccessUtils editPpostWithId:_post.uuid
                          withNewImageData:postImageData
                            withNewCaption:postCaptionString
                          withShopProducts:postShopProducts
                            withCompletion:^(NSArray *objects, NSError *error) {
                                __strong STSharePhotoViewController *strongSelf = weakSelf;
                                strongSelf.shareButton.enabled = TRUE;
                                if (!error) {
                                    STPost *post = [objects firstObject];
                                    if (postShouldBePostedOnFacebook==YES ) {
                                        [strongSelf startPostingWithPostId:post.uuid andImageUrl:post.mainImageUrl deepLink:post.shareShortUrl];
                                    }
                                    else
                                    {
                                        [strongSelf showMessagesAndCallDelegatesForPostId:post.uuid];
                                    }

                                }
                            }];
    }
}

#pragma mark - Helper

- (void)startPostingWithPostId:(NSString *)postId
                   andImageUrl:(NSString *)imageUrl
                      deepLink:(NSString *)deepLink{
    if ([_childTVC postShouldBePostedOnFacebook]) {
        [self postCurrentPhotoToFacebookWithPostId:postId
                                       andImageUrl:imageUrl
                                          deepLink:deepLink];
    }
}
- (void)postCurrentPhotoToFacebookWithPostId:(NSString *)postId
                                 andImageUrl:(NSString *)imageUrl
                                    deepLink:(NSString *)deepLink{
    __weak STSharePhotoViewController *weakSelf = self;
    [[CoreManager facebookService] shareImageWithImageUrl:imageUrl
                                              description:[_childTVC postCaptionString]
                                                 deepLink:deepLink
                                            andCompletion:^(id result, NSError *error) {
                                                __strong STSharePhotoViewController *strongSelf = weakSelf;
                                                strongSelf.donePostingToFacebook = YES;
                                                if (error) {
                                                    strongSelf.fbError = error;
                                                }
                                                [strongSelf showMessagesAndCallDelegatesForPostId:postId];
                                            }];
}

- (void)showMessagesAndCallDelegatesForPostId:(NSString *)postId {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *alertTitle = nil;
        NSString *alertMessage = nil;
        if (self.fbError!=nil){
            alertTitle = @"Warning";
            alertMessage = @"Your photo was posted on STATUS, but not shared on Facebook. You can try sharing it on Facebook from your profile.";
        }else{
            alertTitle = @"Success";
            alertMessage = @"Your photo was posted on STATUS";
        }
        if (alertMessage!=nil) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [[CoreManager navigationService] dismissChoosePhotoVC];

            }]];
            [self.navigationController presentViewController:alert animated:YES completion:nil];
        }
        if ([self.post.uuid isEqualToString:postId]) {
            [[CoreManager localNotificationService] postNotificationName:STPostImageWasEdited object:nil userInfo:@{kPostIdKey:postId}];
        }
        else
            [[CoreManager localNotificationService] postNotificationName:STPostNewImageUploaded object:nil userInfo:@{kPostIdKey:postId}];
    });

}

-(void)showErrorAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Something went wrong. Please try again later." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

@end

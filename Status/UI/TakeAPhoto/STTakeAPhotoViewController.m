//
//  STTakeAPhotoViewController.m
//  Status
//
//  Created by Silviu Burlacu on 28/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STTakeAPhotoViewController.h"
#import "CoreManager.h"
#import "STImagePickerService.h"
#import "STMoveScaleViewController.h"
#import "STNavigationService.h"

#import "STImageCacheController.h"
#import "STPostsPool.h"

@interface STTakeAPhotoViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation STTakeAPhotoViewController

+ (instancetype)newController {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"TakeAPhoto" bundle:[NSBundle mainBundle]];
    STTakeAPhotoViewController * vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([STTakeAPhotoViewController class])];
    return vc;
}

#pragma mark - IBActions

- (IBAction)takeAPhotoWithCamera:(id)sender {
    
    __weak STTakeAPhotoViewController * weakSelf = self;
    imagePickerCompletion completion = ^(UIImage *img, BOOL shouldCompressImage){
        
        STMoveScaleViewController * moveScaleVC = [STMoveScaleViewController newControllerForImage:img shouldCompress:shouldCompressImage andPost:nil];
        [weakSelf.navigationController pushViewController:moveScaleVC animated:YES];
    };
    
    [[CoreManager imagePickerService] takeCameraPictureFromController:self withCompletion:completion];
}

- (IBAction)uploadPhotoFromLibrary:(id)sender {
    __weak STTakeAPhotoViewController * weakSelf = self;
    imagePickerCompletion completion = ^(UIImage *img, BOOL shouldCompressImage){
        
        STMoveScaleViewController * moveScaleVC = [STMoveScaleViewController newControllerForImage:img shouldCompress:shouldCompressImage andPost:nil];
        [weakSelf.navigationController pushViewController:moveScaleVC animated:YES];
    };
    
    [[CoreManager imagePickerService] launchLibraryPickerFromController:self withCompletion:completion];
}

- (IBAction)postPhotoFromFacebook:(id)sender {
    __weak STTakeAPhotoViewController * weakSelf = self;
    imagePickerCompletion completion = ^(UIImage *img, BOOL shouldCompressImage){
        
        STMoveScaleViewController * moveScaleVC = [STMoveScaleViewController newControllerForImage:img shouldCompress:shouldCompressImage andPost:nil];
        [weakSelf.navigationController pushViewController:moveScaleVC animated:YES];
    };
    
    [[CoreManager imagePickerService] launchFacebookPickerFromController:self withCompletion:completion];
}

#pragma mark - Notifications


- (void)imageWasPostedWithPostId:(NSNotification *)notif {
//    NSString *postId = notif.userInfo[kPostIdKey];
    //TODO: redirect to a screen with a single post?
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageWasPostedWithPostId:) name:STPostNewImageUploaded object:nil];

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    __weak typeof(self) weakSelf = self;
    STPost * randomPost = [CoreManager postsPool].randomPost;
    [[CoreManager imageCacheService] loadPostImageWithName:randomPost.fullPhotoUrl withPostCompletion:^(UIImage *origImg) {
        
    } andBlurCompletion:^(UIImage *bluredImg) {
        weakSelf.backgroundImageView.image = bluredImg;
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

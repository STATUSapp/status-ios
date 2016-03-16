//
//  STNavigationService.m
//  Status
//
//  Created by Andrus Cosmin on 29/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STNavigationService.h"
#import "STLoginViewController.h"
#import "AppDelegate.h"
#import "FeedCVC.h"

#import "STImagePickerController.h"
#import "STImagePickerService.h"
#import "STTabBarViewController.h"
#import "STImagePickerService.h"
#import "STMoveScaleViewController.h"

#import "STPost.h"
#import "STPostsPool.h"
#import "STImageCacheController.h"
#import "STSharePhotoViewController.h"

@interface STNavigationService ()

@end

@implementation STNavigationService
-(instancetype)init{
    self = [super init];
    if (self) {
        
        _imagePickerController = [STImagePickerController new];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLoggedIn) name:kNotificationUserDidLoggedIn object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidRegister) name:kNotificationUserDidRegister object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLoggedOut) name:kNotificationUserDidLoggedOut object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMoveAndScaleNotification:) name:STOptionsViewMoveAndScaleNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEditPostNotification:) name:STOptionsViewEditPostNotification object:nil];

    }
    return self;
}

#pragma mark - NSNOtifications
- (void)userDidLoggedIn{
    [self presentTabBarController];
}

- (void)userDidRegister{
    [self presentTabBarController];
}

- (void)userDidLoggedOut{
    [self presentLoginScreen];
}

- (void)onEditPostNotification:(NSNotification *)notif{
    NSString *postId = notif.userInfo[kPostIdKey];
    STPost *post = [[CoreManager postsPool] getPostWithId:postId];
    //TODO: dev_1_2 disable option until image is downloaded
    if (post.imageDownloaded == YES) {
        [[CoreManager imageCacheService] loadPostImageWithName:post.fullPhotoUrl withPostCompletion:^(UIImage *origImg) {
            if (origImg!=nil) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                STSharePhotoViewController *viewController = (STSharePhotoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"shareScene"];
                viewController.imgData = UIImageJPEGRepresentation(origImg, 1.f);
                viewController.bluredImgData = UIImageJPEGRepresentation(origImg, 1.f);
                viewController.post = post;
                viewController.controllerType = STShareControllerEditCaption;
                //TODO: dev_1_2 move all those redirects in here and make some class methods
                UIWindow *window = [[UIApplication sharedApplication].delegate window];
                UITabBarController *tbc = (UITabBarController *)[window rootViewController];
                UINavigationController *navCtrl = (UINavigationController *)[tbc selectedViewController];
                [navCtrl pushViewController:viewController animated:YES];

            }
            
        } andBlurCompletion:nil];
    }

}
- (void)onMoveAndScaleNotification:(NSNotification *)notif{
    NSString *postId = notif.userInfo[kPostIdKey];
    STPost *post = [[CoreManager postsPool] getPostWithId:postId];
    
    //TODO: dev_1_2 disable option until image is downloaded
    if (post.imageDownloaded == YES) {
        [[CoreManager imageCacheService] loadPostImageWithName:post.fullPhotoUrl withPostCompletion:^(UIImage *img) {
            if (img!=nil) {
                STMoveScaleViewController *vc = [STMoveScaleViewController newControllerForImage:img shouldCompress:NO andPost:post];
                
                //TODO: dev_1_2 move all those redirects in here and make some class methods
                UIWindow *window = [[UIApplication sharedApplication].delegate window];
                UITabBarController *tbc = (UITabBarController *)[window rootViewController];
                UINavigationController *navCtrl = (UINavigationController *)[tbc selectedViewController];
                [navCtrl pushViewController:vc animated:YES];
            }
        } andBlurCompletion:nil];
        
    }
}

#pragma mark - Helpers

- (void)presentLoginScreen{
    AppDelegate *appDel=(AppDelegate *)[UIApplication sharedApplication].delegate;
    if ([appDel.window.rootViewController isKindOfClass:[STLoginViewController class]]) {
        return;
    }

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LoginScene" bundle:nil];
    STLoginViewController *viewController = (STLoginViewController *) [storyboard instantiateViewControllerWithIdentifier:@"loginScreen"];
    [appDel.window setRootViewController:viewController];

}

- (void)presentTabBarController{
    NSLog(@"Tabbar Controller presented");
    //TODO: dev_1_2 add tab bar here as root
    AppDelegate *appDel=(AppDelegate *)[UIApplication sharedApplication].delegate;
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UINavigationController *navController = [storyboard instantiateInitialViewController];
//    [appDel.window setRootViewController:navController];
    
    STTabBarViewController * tabBar = [STTabBarViewController newController];
    [appDel.window setRootViewController:tabBar];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

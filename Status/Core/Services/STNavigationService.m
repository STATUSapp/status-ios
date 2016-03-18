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
#import "STFlowTemplate.h"
#import "STPostsPool.h"
#import "STImageCacheController.h"
#import "STSharePhotoViewController.h"
#import "STLocalNotificationService.h"

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flowWasSelectedFromFooter:) name:STFooterFlowsNotification object:nil];

    }
    return self;
}

#pragma mark - Methods
-(void)switchToTabBarAtIndex:(NSInteger)index
                 popToRootVC:(BOOL)popToRoot{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    UITabBarController *tbc = (UITabBarController *)[window rootViewController];
    [tbc setSelectedIndex:index];
    if (popToRoot) {
        UINavigationController *navCtrl = (UINavigationController *)[[tbc viewControllers] objectAtIndex:index];
        [navCtrl popToRootViewControllerAnimated:YES];
    }
}

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
    AppDelegate *appDel=(AppDelegate *)[UIApplication sharedApplication].delegate;
    STTabBarViewController * tabBar = [STTabBarViewController newController];
    [appDel.window setRootViewController:tabBar];
}

- (void)resetTabBarStacks{
    //TODO: dev_1_2 should we reset some nav controller?
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
                [self pushViewController:vc inTabBarIndex:[self selectedTabBarIndex] animated:YES];
            }
        } andBlurCompletion:nil];
        
    }
}

-(void) flowWasSelectedFromFooter:(NSNotification *)notif{
    NSString *flowType = [[notif userInfo] objectForKey:kFlowTypeKey];
    if ([flowType isEqualToString:@"home"]) {
        //go to home tab and refresh the data
        [self switchToTabBarAtIndex:STTabBarIndexHome popToRootVC:YES];
        [[CoreManager localNotificationService] postNotificationName:STHomeFlowShouldBeReloadedNotification object:nil userInfo:nil];
        
    }
    else if ([flowType isEqualToString:@"popular"]){
        //TODO: dev_1_2 go to search tab
    }
    else if ([flowType isEqualToString:@"recent"]){
        //TODO: dev_1_2 go to search tab
    }
    else if ([flowType isEqualToString:@"nearby"]){
        //TODO: dev_1_2 go to search tab
    }

}

#pragma mark - Helpers

-(NSInteger)selectedTabBarIndex{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    UITabBarController *tbc = (UITabBarController *)[window rootViewController];
    return tbc.selectedIndex;
}

-(void)pushViewController:(UIViewController *)vc
            inTabBarIndex:(NSInteger)index
                 animated:(BOOL)animated{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    UITabBarController *tbc = (UITabBarController *)[window rootViewController];
    UINavigationController *navCtrl = (UINavigationController *)[[tbc viewControllers] objectAtIndex:index];
    [navCtrl pushViewController:vc animated:animated];

}

+ (UIViewController *)viewControllerForSelectedTab{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    UITabBarController *tbc = (UITabBarController *)[window rootViewController];
    UINavigationController *navCtrl = (UINavigationController *)[tbc selectedViewController];
    return [[navCtrl viewControllers] lastObject];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

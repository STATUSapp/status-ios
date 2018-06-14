//
//  STDeepLinkService.m
//  Status
//
//  Created by Cosmin Andrus on 26/06/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STDeepLinkService.h"
#import "STLoginService.h"
#import "STNavigationService.h"

#import "ContainerFeedVC.h"

NSString * const kNonBrankLinkKey = @"+non_branch_link";
NSString * const kDeepLinkPathKey = @"$deeplink_path";

NSString * const kHostUserKey = @"user";
NSString * const kHostPostKey = @"post";

@interface STDeepLinkService()

@property (nonatomic, strong) NSDictionary *redirectParams;

@end

@implementation STDeepLinkService

- (NSArray <UIViewController *> *)redirectViewControllers{
    if (!_redirectParams) {
        return nil;
    }
    
    if ([[CoreManager loginService] currentUserUuid]) {
        //user logged in
        NSMutableArray *stackVC = [@[] mutableCopy];
        NSString *redirectLink = _redirectParams[kDeepLinkPathKey];
        if (!redirectLink) {
            redirectLink = _redirectParams[kNonBrankLinkKey];
        }
        
        if (redirectLink) {
            NSURL *url = [NSURL URLWithString:redirectLink];
            NSString *hostString = [url host];
            NSMutableArray *components = [[url pathComponents] mutableCopy];
            [components removeObject:@"/"];
            NSLog(@"scheme: %@", [url scheme]);
            NSLog(@"host: %@", [url host]);
            NSLog(@"path: %@", [url path]);
            NSLog(@"path components: %@", components);
            
            NSString *userId = nil;
            if ([components count] > 0) {
                userId = components[0];
            }
            
            NSString *postId = nil;
            if ([components count] > 1) {
                postId = components[1];
            }

            if ([hostString isEqualToString:kHostUserKey]) {
                //go to user profile
                if (userId) {
                    ContainerFeedVC *profileVC = [ContainerFeedVC galleryFeedControllerForUserId:userId andUserName:nil];
                    [stackVC addObject:profileVC];
                }
            }else if ([hostString isEqualToString:kHostPostKey]){
                //go to user post
                if (userId) {
                    ContainerFeedVC *profileVC = [ContainerFeedVC galleryFeedControllerForUserId:userId andUserName:nil];
                    [stackVC addObject:profileVC];
                }
                
                if (postId) {
                    ContainerFeedVC *feedCVC = [ContainerFeedVC singleFeedControllerWithPostId:postId];
                    [stackVC addObject:feedCVC];
                    
                }

            }
        }
        [self reset];
        return stackVC;
    }
    //wait for the login, then present the link redirect
    return nil;
}
- (void) addParams:(NSDictionary *)redirectParams{
    _redirectParams = redirectParams;
    
    NSArray *redirectVC = [self redirectViewControllers];
    if (redirectVC && [redirectVC count]) {
        [[CoreManager navigationService] pushViewControllers:redirectVC
                                             inTabbarAtIndex:STTabBarIndexHome];
    }
}

-(void)reset{
    _redirectParams = nil;
}

@end

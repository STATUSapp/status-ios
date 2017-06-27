//
//  STDeepLinkService.m
//  Status
//
//  Created by Cosmin Andrus on 26/06/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STDeepLinkService.h"
#import "STFacebookLoginController.h"
#import "STNavigationService.h"

#import "FeedCVC.h"

NSString * const kNonBrankLinkKey = @"+non_branch_link";

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
        NSString *redirectLink = _redirectParams[kNonBrankLinkKey];
        if (redirectLink) {
            NSURL *url = [NSURL URLWithString:redirectLink];
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
            
            if (userId) {
                FeedCVC *profileVC = [FeedCVC galleryFeedControllerForUserId:userId andUserName:nil];
                profileVC.shouldAddBackButton = YES;
                [stackVC addObject:profileVC];
            }
            
            if (postId) {
                FeedCVC *feedCVC = [FeedCVC singleFeedControllerWithPostId:postId];
                feedCVC.shouldAddBackButton = YES;
                [stackVC addObject:feedCVC];

            }
        }
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
                                             inTabbarAtIndex:STTabBarIndexHome keepThecurrentStack:YES];
    }
}

-(void)reset{
    _redirectParams = nil;
}

@end

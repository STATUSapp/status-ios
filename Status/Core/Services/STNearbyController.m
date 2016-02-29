//
//  STNearbyController.m
//  Status
//
//  Created by Silviu Burlacu on 25/01/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STNearbyController.h"
#import "STUserProfileViewController.h"

#import "STLocationManager.h"
#import "STGetNearbyProfilesRequest.h"

@interface STNearbyController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, STUserProfileControllerDelegate>{
    UIScrollView *_contentScrollView;
}

@property (strong, nonatomic) UIPageViewController * pageViewController;
@property (strong, nonatomic) NSMutableArray * profiles;

@end

@implementation STNearbyController


- (void)getProfilesFromServerWithOffset:(NSInteger)offset withCompletion:(STCompletionBlock)completionBlock {
    
    if (_profiles == nil) {
        _profiles = [NSMutableArray array];
    }
    
    __weak STNearbyController * weakSelf = self;
    
    STRequestCompletionBlock completion = ^(id response, NSError *error){
        if ([response[@"status_code"] integerValue] == 404) {
            //user has no location force an update
            
            [[CoreManager locationService] startLocationUpdatesWithCompletion:^{
                [weakSelf getProfilesFromServerWithOffset:offset withCompletion:completionBlock];
            }];
        }
        else
        {
            NSArray *newPosts = response[@"data"];
            
            for (NSDictionary * userProfileDict in newPosts) {
                STUserProfile * userProfile = [STUserProfile userProfileWithDict:userProfileDict];
                [weakSelf.profiles addObject:userProfile];
            }
            if (completionBlock) {
                completionBlock(nil);
            }
        }
    };
    
    STRequestFailureBlock failBlock = ^(NSError *error){
        NSLog(@"error with %@", error.description);
        if (completionBlock) {
            completionBlock(nil);
        }
    };
    
    [STGetNearbyProfilesRequest getNearbyProfilesWithOffset:offset withCompletion:completion failure:failBlock ];
}

- (void)pushNearbyFlowFromController:(UIViewController *)viewController withCompletionBlock:(STCompletionBlock)completionBlock{
    if (_pageViewController == nil) {
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;        
    }
    
    [self getProfilesFromServerWithOffset:_profiles.count withCompletion:^(NSError *error) {
        if (error == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                STUserProfileViewController * userVC = [STUserProfileViewController newControllerWithUserUserDataModel:_profiles.firstObject];
                userVC.isLaunchedFromNearbyController = YES;
                userVC.delegate = self;
                [self.pageViewController setViewControllers:@[userVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
                [viewController.navigationController pushViewController:self.pageViewController animated:YES];
            });
        }
        completionBlock(error);

    }];
}

#pragma mark UIPageViewController delegate and data source methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(STUserProfileViewController *)viewController {
    NSInteger actualVCIndex = [self indexOfProfile:[viewController userProfile]];
    if (actualVCIndex == ( _profiles.count - 5 )) {
        [self getProfilesFromServerWithOffset:_profiles.count withCompletion:nil];
    }
    
    if (actualVCIndex == _profiles.count - 1 || actualVCIndex == NSNotFound) {
        return nil;
    }
    
    STUserProfileViewController * userVC = [STUserProfileViewController newControllerWithUserUserDataModel:[_profiles objectAtIndex:actualVCIndex + 1]];
    userVC.isLaunchedFromNearbyController = YES;
    userVC.delegate = self;
    return userVC;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(STUserProfileViewController *)viewController {
    NSInteger actualVCIndex = [self indexOfProfile:[viewController userProfile]];

    
    if (actualVCIndex == 0 || actualVCIndex == NSNotFound) {
        return nil;
    }
    
    STUserProfileViewController * userVC = [STUserProfileViewController newControllerWithUserUserDataModel:[_profiles objectAtIndex:actualVCIndex - 1]];
    userVC.isLaunchedFromNearbyController = YES;
    userVC.delegate = self;
    return userVC;
}

#pragma mark - STUserProfileDelegate

- (void)advanceToNextProfile {
    STUserProfileViewController * currentVC = (STUserProfileViewController *)(_pageViewController.viewControllers.firstObject);
    STUserProfileViewController * userVC = (STUserProfileViewController *)[self pageViewController:_pageViewController viewControllerAfterViewController:currentVC];
    if (userVC != nil) {
        [_pageViewController setViewControllers:@[userVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
}


- (NSUInteger)indexOfProfile:(STUserProfile *)userProfile {
    for (STUserProfile * profile in _profiles) {
        
        if ([userProfile.uuid isEqualToString: profile.uuid]) {
            return [_profiles indexOfObject:profile];
        }
    }
    return NSNotFound;
}

@end

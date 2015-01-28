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

@interface STNearbyController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController * pageViewController;
@property (strong, nonatomic) NSMutableArray * profiles;

@end

@implementation STNearbyController


- (void)getProfilesFromServerWithOffset:(NSInteger)offset {
    
    if (_profiles == nil) {
        _profiles = [NSMutableArray array];
    }
    
    __weak STNearbyController * weakSelf = self;
    
    STRequestCompletionBlock completion = ^(id response, NSError *error){
        if ([response[@"status_code"] integerValue] == 404) {
            //user has no location force an update
            
            [[STLocationManager sharedInstance] startLocationUpdatesWithCompletion:^{
                [weakSelf getProfilesFromServerWithOffset:offset];
            }];
        }
        else
        {
//            NSArray *newPosts = [self removeDuplicatesFromArray:response[@"data"]];
//            [weakSelf.profiles addObjectsFromArray:newPosts];
//            _isDataSourceLoaded = YES;
        }
    };
    
    STRequestFailureBlock failBlock = ^(NSError *error){
        NSLog(@"error with %@", error.description);
        dispatch_async(dispatch_get_main_queue(), ^{
//            [weakSelf.refreshBt setEnabled:YES];
//            [weakSelf.refreshBt setTitle:@"Refresh" forState:UIControlStateNormal];
        });
    };
    
    [STGetNearbyProfilesRequest getNearbyProfilesWithOffset:offset withCompletion:completion failure:failBlock ];
}

- (void)pushNearbyFlowFromController:(UIViewController *)viewController {
    
    [self getProfilesFromServerWithOffset:0];
    
    if (_pageViewController == nil) {
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        _pageViewController.delegate = self;
    }
    
    [viewController.navigationController pushViewController:_pageViewController animated:YES];
}

#pragma mark UIPageViewController delegate and data source methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(STUserProfileViewController *)viewController {
    NSInteger actualVCIndex = [_profiles indexOfObject:[viewController userProfileDict]];
    NSString * profileId = nil;
//    if (actualVCIndex > ) {
//        <#statements#>
//    }
//    
    
    return [STUserProfileViewController newControllerWithUserId:profileId];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(STUserProfileViewController *)viewController {
    NSString * profileId = nil;
    return [STUserProfileViewController newControllerWithUserId:profileId];
}

@end

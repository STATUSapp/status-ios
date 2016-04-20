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

#import "STFlowProcessor.h"
#import "STProcessorsService.h"

@interface STNearbyController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, STUserProfileControllerDelegate>{
    UIScrollView *_contentScrollView;
    UIViewController *parentVC;
}

@property (strong, nonatomic) UIPageViewController * pageViewController;
@property (nonatomic, strong) STFlowProcessor *feedProcessor;

@end

@implementation STNearbyController


-(instancetype)init{
    self = [super init];
    if (self) {
        _feedProcessor = [[CoreManager processorService] getProcessorWithType:STFlowTypeDiscoverNearby];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processorLoaded) name:kNotificationObjDownloadSuccess object:_feedProcessor];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postUpdated:) name:kNotificationObjUpdated object:_feedProcessor];

    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notifications

- (void)processorLoaded{
    STUserProfile *up = [_feedProcessor objectAtIndex:0];
    
    STUserProfileViewController * userVC = [STUserProfileViewController newControllerWithUserUserDataModel:up];
    userVC.isLaunchedFromNearbyController = YES;
    userVC.delegate = self;
    [self.pageViewController setViewControllers:@[userVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [parentVC.navigationController pushViewController:self.pageViewController animated:YES];
}

- (void)postUpdated:(NSNotification *)notif{
    
}

- (void)addChild {
    if ([_feedProcessor loading] == NO) {
        STUserProfile *up = [_feedProcessor objectAtIndex:[_feedProcessor currentOffset]];
        STUserProfileViewController * userVC = [STUserProfileViewController newControllerWithUserUserDataModel:up];
        userVC.isLaunchedFromNearbyController = YES;
        userVC.delegate = self;
        [self.pageViewController setViewControllers:@[userVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        [parentVC.navigationController pushViewController:self.pageViewController animated:YES];
    }
}

- (void)pushNearbyFlowFromController:(UIViewController *)viewController{
    parentVC = viewController;
    if (_pageViewController == nil) {
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
        
        [self addChild];
    }
    else
    {
        [self addChild];
    }
}

#pragma mark UIPageViewController delegate and data source methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(STUserProfileViewController *)viewController {
    NSInteger actualVCIndex = [self indexOfProfile:[viewController userProfile]];
    
    if (actualVCIndex == _feedProcessor.numberOfObjects - 1 || actualVCIndex == NSNotFound) {
        return nil;
    }
    
    STUserProfileViewController * userVC = [STUserProfileViewController newControllerWithUserUserDataModel:[_feedProcessor objectAtIndex:actualVCIndex + 1]];
    userVC.isLaunchedFromNearbyController = YES;
    userVC.delegate = self;
    return userVC;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(STUserProfileViewController *)viewController {
    NSInteger actualVCIndex = [self indexOfProfile:[viewController userProfile]];

    
    if (actualVCIndex == 0 || actualVCIndex == NSNotFound) {
        return nil;
    }
    
    STUserProfileViewController * userVC = [STUserProfileViewController newControllerWithUserUserDataModel:[_feedProcessor objectAtIndex:actualVCIndex - 1]];
    userVC.isLaunchedFromNearbyController = YES;
    userVC.delegate = self;
    return userVC;
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<STUserProfileViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed{
    NSInteger currentIndex = [self indexOfProfile:[[previousViewControllers lastObject] userProfile]];
    [_feedProcessor processObjectAtIndex:currentIndex setSeenIfRequired:NO];
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
    return [_feedProcessor indexOfObject:userProfile];
}

@end

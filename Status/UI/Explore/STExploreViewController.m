//
//  STExploreViewController.m
//  Status
//
//  Created by Cosmin Andrus on 27/11/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STExploreViewController.h"
#import "STCustomSegment.h"
#import "STFlowProcessor.h"
#import "CoreManager.h"
#import "STProcessorsService.h"
#import "FeedCVC.h"
#import "NearbyVC.h"
#import "STExploreFilters.h"

typedef NS_ENUM(NSUInteger, STExploreFlow) {
    STExploreFlowPopular = 0,
//    STExploreFlowNearby,
    STExploreFlowRecent,
    STExploreFlowCount
};

const CGFloat kFiltersDefaultHeight = 41.f;

@interface STExploreViewController ()<STSCustomSegmentProtocol, UIPageViewControllerDelegate, UIPageViewControllerDataSource, STSideBySideContaineeProtocol, STExploreFiltersProtocol>
@property (weak, nonatomic) IBOutlet UIView *topViewContainer;
@property (weak, nonatomic) IBOutlet UIView *filtersViewContainer;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) UIPageViewController * pageController;
@property (strong, nonatomic) NSArray<FeedCVC *> * viewControllers;
@property (strong, nonatomic) STCustomSegment *customSegment;
@property (strong, nonatomic) NSArray <STExploreFilters *> *filterViewArray;//one option for each segment

@end

@implementation STExploreViewController

+ (STExploreViewController *)exploreViewController{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ExploreScene" bundle:nil];
    STExploreViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"EXPLORE_VC"];
    
    return vc;
}

#pragma mark - STExploreFiltersProtocol

-(STExploreFiltersTimeframe)defaultTimeframeOptionWithSender:(STExploreFilters *)sender{
    
    NSInteger filterIndex = [_filterViewArray indexOfObject:sender];
    if (filterIndex == NSNotFound) {
        NSLog(@"FILTER NOT FOUND!");
    }else{
        FeedCVC *feedController = _viewControllers[filterIndex];
        STFlowProcessor *processor = feedController.feedProcessor;
        //load default values
        NSString *timeframe = processor.timeframeFilter;
        if ([timeframe isEqualToString:kTimeframeDaily]) {
            return STExploreFiltersTimeframeDaily;
        }
        if ([timeframe isEqualToString:kTimeframeMonthly]) {
            return STExploreFiltersTimeframeMonthly;
        }
        if ([timeframe isEqualToString:kTimeframeWeekly]) {
            return STExploreFiltersTimeframeWeekly;
        }
        if ([timeframe isEqualToString:kTimeframeAllTime]) {
            return STExploreFiltersTimeframeAllTime;
        }
    }
    
    NSLog(@"DEFAULT TIMEFRAME FILTER NOT FOUND!");
    return STExploreFiltersTimeframeDaily;
}
-(STExploreFiltersGender)defaultGenderOptionWithSender:(STExploreFilters *)sender{
    
    NSInteger filterIndex = [_filterViewArray indexOfObject:sender];
    if (filterIndex == NSNotFound) {
        NSLog(@"FILTER NOT FOUND!");
    }else{
        FeedCVC *feedController = _viewControllers[filterIndex];
        STFlowProcessor *processor = feedController.feedProcessor;
        //load default values
        
        NSString *gender = processor.genderFilter;
        
        if ([gender isEqualToString:kGenderWomen]) {
            return STExploreFiltersGenderWomen;
        }else if ([gender isEqualToString:kGenderMen]) {
            return STExploreFiltersGenderMen;
        }else{
            return STExploreFiltersGenderBoth;
        }
    }
    
    NSLog(@"DEFAULT GENDER FILTER NOT FOUND!");
    return STExploreFiltersGenderBoth;

}
-(void)filtersChangedInTimeFrame:(STExploreFiltersTimeframe)timeframeOption
                       andGender:(STExploreFiltersGender)genderOption
                       forSender:(STExploreFilters *)sender{
    NSString *timeframe = nil;
    switch (timeframeOption) {
        case STExploreFiltersTimeframeDaily:
            timeframe = kTimeframeDaily;
            break;
        case STExploreFiltersTimeframeWeekly:
            timeframe = kTimeframeWeekly;
            break;
        case STExploreFiltersTimeframeMonthly:
            timeframe = kTimeframeMonthly;
            break;
        case STExploreFiltersTimeframeAllTime:
            timeframe = kTimeframeAllTime;
            break;
    }

    NSString *gender = nil;
    switch (genderOption) {
        case STExploreFiltersGenderWomen:
            gender = kGenderWomen;
            break;
        case STExploreFiltersGenderMen:
            gender = kGenderMen;
            break;
        default:
            break;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    if (timeframe) {
        [userInfo setValue:timeframe forKey:@"timeframe"];
    }
    
    if (gender) {
        [userInfo setValue:gender forKey:@"gender"];
    }
    
    NSInteger filterIndex = [_filterViewArray indexOfObject:sender];
    if (filterIndex == NSNotFound) {
        NSLog(@"FILTER NOT FOUND!");
    }else{
        FeedCVC *feedController = _viewControllers[filterIndex];
        STFlowProcessor *processor = feedController.feedProcessor;
        [userInfo setValue:@(processor.processorFlowType) forKey:@"processor_type"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFiltersChanged object:nil userInfo:userInfo];
    }

}

#pragma mark STSCustomSegmentProtocol

-(CGFloat)segmentBottomSpace:(STCustomSegment *)segment{
    return 0.f;
}

-(CGFloat)segmentTopSpace:(STCustomSegment *)segment{
    return 0.f;
}

-(NSInteger)segmentNumberOfButtons:(STCustomSegment *)segment{
    return STExploreFlowCount;
}

-(NSString *)segment:(STCustomSegment *)segment buttonTitleForIndex:(NSInteger)index{
    switch (index) {
//        case STExploreFlowNearby:
//            return @"NEARBY";
//            break;
//            
        case STExploreFlowRecent:
            return @"RECENT";
            break;
            
        case STExploreFlowPopular:
            return @"POPULAR";
            break;
        default:
            break;
    }
    
    return @"";
}

-(void)segment:(STCustomSegment *)segment buttonPressedAtIndex:(NSInteger)index{
    NSLog(@"Button pressed: %ld",(long)index);
    
    NSInteger currentVCIndex = [_viewControllers indexOfObject:_pageController.viewControllers.lastObject];

    [self configureFilterContainer];

    if (index == currentVCIndex) {
        return;
    }
    
    UIPageViewControllerNavigationDirection direction = index > currentVCIndex ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    
    [_pageController setViewControllers:@[_viewControllers[index]] direction:direction animated:YES completion:nil];

}

-(void)configureFilterContainer{
    NSInteger index = _customSegment.selectedIndex;
    STExploreFilters *filterView = _filterViewArray[index];
    CGRect rect = filterView.frame;
    rect.origin.x = 0.f;
    rect.origin.y = 0.f;
    rect.size.height = self.filtersViewContainer.frame.size.height;
    rect.size.width = self.filtersViewContainer.frame.size.width;
    filterView.frame = rect;
    filterView.translatesAutoresizingMaskIntoConstraints = YES;
    filterView.tag = 101;
    STExploreFilters *oldView = [self.filtersViewContainer viewWithTag:101];
    [oldView removeFromSuperview];
    [self.filtersViewContainer addSubview:filterView];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    _customSegment = [STCustomSegment customSegmentWithDelegate:self];
    [_customSegment configureSegmentWithDelegate:self];
    CGRect rect = _customSegment.frame;
    rect.origin.x = 0.f;
    rect.origin.y = 0.f;
    rect.size.height = self.topViewContainer.frame.size.height;
    rect.size.width = self.topViewContainer.frame.size.width;
    _customSegment.frame = rect;
    _customSegment.translatesAutoresizingMaskIntoConstraints = YES;

    [self.topViewContainer addSubview:_customSegment];
    
    NSMutableArray <UIViewController *> *viewControllers = [NSMutableArray new];
    for (int i=0; i<STExploreFlowCount; i++) {
        STFlowType flowType = STFlowTypeHome;
        switch (i) {
            case STExploreFlowRecent:
                flowType = STFlowTypeRecent;
                break;
            case STExploreFlowPopular:
                flowType = STFlowTypePopular;
                break;
        }
        STFlowProcessor *feedProcessor = [[CoreManager processorService] getProcessorWithType:flowType];
        
        FeedCVC *vc = [FeedCVC feedControllerWithFlowProcessor:feedProcessor];
        vc.containeeDelegate = self;
        [viewControllers addObject:vc];
    }
    
    _viewControllers = [NSArray arrayWithArray:viewControllers];
    
    NSMutableArray *filterArray = [NSMutableArray new];
    for (int i = 0; i<STExploreFlowCount; i++) {
        STExploreFiltersType filterType;
        switch (i) {
            case STExploreFlowRecent:
                filterType = STExploreFiltersTypeRecent;
                break;
            case STExploreFlowPopular:
                filterType = STExploreFiltersTypePopular;
                break;
        }

        STExploreFilters *filter = [STExploreFilters exploreFiltersWithDelegate:self andType:filterType];
        [filterArray addObject:filter];
    }
    _filterViewArray = [NSArray arrayWithArray:filterArray];
    [self configureFilterContainer];
    
    _pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    _pageController.view.backgroundColor = [UIColor clearColor];
    _pageController.view.tintColor = [UIColor clearColor];
    
    _pageController.delegate = self;
    _pageController.dataSource = self;
    
    [_pageController setViewControllers:@[_viewControllers.firstObject] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    _pageController.view.frame = self.containerView.bounds;
    [self.containerView addSubview:_pageController.view];
    [self addChildViewController:_pageController];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(BOOL)extendedLayoutIncludesOpaqueBars{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Containees notifications

- (void)containeeEndedScrolling {
    for (UIView * view in _pageController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            [((UIScrollView *)view) setScrollEnabled:YES];
        }
    }
}

- (void)containeeStartedScrolling {
    for (UIView * view in _pageController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            [((UIScrollView *)view) setScrollEnabled:NO];
        }
    }
}

-(UITabBarController *)containeeTabBarController{
    return self.tabBarController;
}
#pragma mark - UIPageViewController Delegate and Datasource


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger currentIndex = [_viewControllers indexOfObject:(FeedCVC *)viewController];
    if (currentIndex + 1 < _viewControllers.count) {
        return _viewControllers[currentIndex + 1];
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSInteger currentIndex = [_viewControllers indexOfObject:(FeedCVC *)viewController];
    if (currentIndex > 0) {
        return _viewControllers[currentIndex - 1];
    }
    return nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    NSLog(@"transition");
    
    if (completed) {
        
        NSLog(@"completed");
        
        
        NSInteger currentVCIndex = [_viewControllers indexOfObject:pageViewController.viewControllers.lastObject];
        [_customSegment selectSegmentIndex:currentVCIndex];

    }
    
    for (UIViewController * controller in _viewControllers) {
        if ([controller respondsToSelector:@selector(containerEndedScrolling)]) {
            [controller performSelector:@selector(containerEndedScrolling) withObject:nil];
        }
    }
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    for (UIViewController * controller in _viewControllers) {
        if ([controller respondsToSelector:@selector(containerStartedScrolling)]) {
            [controller performSelector:@selector(containerStartedScrolling) withObject:nil];
        }
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

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

typedef NS_ENUM(NSUInteger, STExploreFlow) {
    STExploreFlowPopular = 0,
//    STExploreFlowNearby,
    STExploreFlowRecent,
    STExploreFlowCount
};

const CGFloat kFiltersDefaultHeight = 41.f;

@interface STExploreViewController ()<STSCustomSegmentProtocol, UIPageViewControllerDelegate, UIPageViewControllerDataSource, STSideBySideContaineeProtocol>
@property (weak, nonatomic) IBOutlet UIView *topViewContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *popularFIlterViewHeightConstr;
@property (weak, nonatomic) IBOutlet UIButton *dailyButton;
@property (weak, nonatomic) IBOutlet UIButton *weeklyButton;
@property (weak, nonatomic) IBOutlet UIButton *monthlyButton;
@property (weak, nonatomic) IBOutlet UIButton *allTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *womenButton;
@property (weak, nonatomic) IBOutlet UIButton *menButton;
@property (weak, nonatomic) IBOutlet UIButton *bothButton;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) UIPageViewController * pageController;
@property (strong, nonatomic) NSArray<UIViewController *> * viewControllers;
@property (strong, nonatomic) STCustomSegment *customSegment;
@property (strong, nonatomic) UIButton *selectedTimeframe;
@property (strong, nonatomic) UIButton *selectedGender;

@end

@implementation STExploreViewController

+ (STExploreViewController *)exploreViewController{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ExploreScene" bundle:nil];
    STExploreViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"EXPLORE_VC"];
    
    return vc;
}

#pragma mark - IBACTIONS
- (IBAction)timeframeOptionSelected:(id)sender {
    if (_selectedTimeframe!=sender) {
        _selectedTimeframe = sender;
        [self configureFilters];
        [self invalidateDatasource];
    }
}

- (IBAction)genderOptionSelected:(id)sender {
    if (_selectedGender!=sender) {
        _selectedGender = sender;
        [self configureFilters];
        [self invalidateDatasource];
    }
}
#pragma mark - Helpers

-(void)configureFilters{
    [_dailyButton setSelected:_dailyButton==_selectedTimeframe];
    [_weeklyButton setSelected:_weeklyButton==_selectedTimeframe];
    [_monthlyButton setSelected:_monthlyButton==_selectedTimeframe];
    [_allTimeButton setSelected:_allTimeButton==_selectedTimeframe];
    
    [_womenButton setSelected:_womenButton==_selectedGender];
    [_menButton setSelected:_menButton==_selectedGender];
    [_bothButton setSelected:_bothButton==_selectedGender];
}

-(void)invalidateDatasource{
    NSString *timeframe = nil;
    if (_dailyButton == _selectedTimeframe) {
        timeframe = kPopularTimeframeDaily;
    }
    if (_weeklyButton == _selectedTimeframe) {
        timeframe = kPopularTimeframeWeekly;
    }
    if (_monthlyButton == _selectedTimeframe) {
        timeframe = kPopularTimeframeMonthly;
    }
    if (_allTimeButton == _selectedTimeframe) {
        timeframe = kPopularTimeframeAllTime;
    }
    NSString *gender = nil;
    if (_womenButton == _selectedGender) {
        gender = kPopularGenderWomen;
    }
    if (_menButton == _selectedGender) {
        gender = kPopularGenderMen;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    if (timeframe) {
        [userInfo setValue:timeframe forKey:@"timeframe"];
    }
    else
        NSLog(@"YOU SHOULD NEVER BE HERE!!!");
    
    if (gender) {
        [userInfo setValue:gender forKey:@"gender"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPopularFiltersChanged object:nil userInfo:userInfo];
}

-(void)loadDefaultFiltersForProcessor:(STFlowProcessor *) processor{
    //load default values
    NSString *timeframe = processor.popularTimeframe;
    NSString *gender = processor.popularGender;
    if ([timeframe isEqualToString:kPopularTimeframeDaily]) {
        _selectedTimeframe = _dailyButton;
    }
    if ([timeframe isEqualToString:kPopularTimeframeMonthly]) {
        _selectedTimeframe = _monthlyButton;
    }
    if ([timeframe isEqualToString:kPopularTimeframeWeekly]) {
        _selectedTimeframe = _weeklyButton;
    }
    if ([timeframe isEqualToString:kPopularTimeframeAllTime]) {
        _selectedTimeframe = _allTimeButton;
    }
    
    if ([gender isEqualToString:kPopularGenderWomen]) {
        _selectedGender = _womenButton;
    }
    
    if ([gender isEqualToString:kPopularGenderMen]) {
        _selectedGender = _menButton;
    }
    
    if (!_selectedGender) {
        _selectedGender = _bothButton;
    }
    
    [self configureFilters];
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
    
    if (index == currentVCIndex) {
        return;
    }
    
    _popularFIlterViewHeightConstr.constant = (index == STExploreFlowPopular)?kFiltersDefaultHeight:0.f;
    
    UIPageViewControllerNavigationDirection direction = index > currentVCIndex ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    
    [_pageController setViewControllers:@[_viewControllers[index]] direction:direction animated:YES completion:nil];

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
        
        if (flowType == STFlowTypePopular) {
            [self loadDefaultFiltersForProcessor:feedProcessor];
        }
        FeedCVC *vc = [FeedCVC feedControllerWithFlowProcessor:feedProcessor];
        vc.containeeDelegate = self;
        [viewControllers addObject:vc];
    }
    
    _viewControllers = [NSArray arrayWithArray:viewControllers];

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
    NSInteger currentIndex = [_viewControllers indexOfObject:viewController];
    if (currentIndex + 1 < _viewControllers.count) {
        return _viewControllers[currentIndex + 1];
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSInteger currentIndex = [_viewControllers indexOfObject:viewController];
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

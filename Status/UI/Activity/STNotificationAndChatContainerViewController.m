//
//  STNotificationAndChatContainerViewController.m
//  Status
//
//  Created by test on 08/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STNotificationAndChatContainerViewController.h"

#import "STNotificationsViewController.h"
#import "STConversationsListViewController.h"
#import "STNotificationsManager.h"
#import "BadgeService.h"
#import "STNavigationService.h"
#import "STCustomSegment.h"

//typedef NS_ENUM(NSUInteger, STActivity) {
//    STActivityNotifications = 0,
//    STActivityChat,
//    STActivityCount
//};

@interface STNotificationAndChatContainerViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>
//@property (weak, nonatomic) IBOutlet UIView *topContainerView;

@property (weak, nonatomic) IBOutlet UIView *childContainer;

//@property (strong, nonatomic) STCustomSegment *customSegment;

@property (strong, nonatomic) UIPageViewController * pageController;
@property (strong, nonatomic) NSArray<UIViewController *> * viewControllers;

@property (strong, nonatomic) UIViewController * lastReturnedViewController;

@end

@implementation STNotificationAndChatContainerViewController

+ (instancetype)newController {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"ChatScene" bundle:[NSBundle mainBundle]];
    return [storyboard instantiateViewControllerWithIdentifier:@"STNotificationAndChatContainerViewController"];
}

/*
#pragma mark STSCustomSegmentProtocol

-(CGFloat)segmentBottomSpace:(STCustomSegment *)segment{
    return 9.f;
}

-(CGFloat)segmentTopSpace:(STCustomSegment *)segment{
    return 9.f;
}

-(NSInteger)segmentNumberOfButtons:(STCustomSegment *)segment{
    return STActivityCount;
}

-(NSString *)segment:(STCustomSegment *)segment buttonTitleForIndex:(NSInteger)index{
    switch (index) {
        case STActivityNotifications:
            return @"ACTIVITY";
            break;
            
        case STActivityChat:
            return @"MESSAGES";
            break;
        default:
            break;
    }
    
    return @"";
}

-(NSInteger)segmentDefaultSelectedIndex:(STCustomSegment *)segment{
    return STActivityChat;
}

-(void)segment:(STCustomSegment *)segment buttonPressedAtIndex:(NSInteger)index{
    NSLog(@"Button pressed: %ld",(long)index);
    
    NSInteger currentVCIndex = [_viewControllers indexOfObject:_pageController.viewControllers.lastObject];
    
    if (index == STActivityChat) {
        [self goToMessages:nil];
    }
    else
        [self goToNotifications:nil];
    
    if (index == currentVCIndex) {
        return;
    }
    
    UIPageViewControllerNavigationDirection direction = index > currentVCIndex ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    
    [_pageController setViewControllers:@[_viewControllers[index]] direction:direction animated:YES completion:nil];
}
*/
#pragma mark - IBActions

//- (IBAction)goToMessages:(id)sender {
//    [[CoreManager navigationService] showMessagesIconOnTabBar];
//    [[CoreManager badgeService] setBadgeForMessages];
//}
- (IBAction)goToNotifications:(id)sender {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[CoreManager navigationService] showActivityIconOnTabBar];
        [[CoreManager badgeService] setBadgeForNotifications];
    });
}

#pragma mark - UIPageViewController Delegate and Datasource


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger currentIndex = [_viewControllers indexOfObject:viewController];
    if (currentIndex + 1 < _viewControllers.count) {
        
        _lastReturnedViewController = _viewControllers[++currentIndex];
        return _lastReturnedViewController;
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSInteger currentIndex = [_viewControllers indexOfObject:viewController];
    if (currentIndex > 0) {
        _lastReturnedViewController =  _viewControllers[--currentIndex];
        return _lastReturnedViewController;
    }
    return nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    NSLog(@"transition");
    
    if (completed) {
        
        NSLog(@"completed");
        
        
//        NSInteger currentVCIndex = [_viewControllers indexOfObject:pageViewController.viewControllers.lastObject];
        
//        [_customSegment selectSegmentIndex:currentVCIndex];
//        
//        if (currentVCIndex == STActivityChat) {
//            [self goToMessages:nil];
//        }
//        else
            [self goToNotifications:nil];
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

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIStoryboard * mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    STNotificationsViewController *notifController = [mainStoryboard instantiateViewControllerWithIdentifier: @"notificationScene"];
    notifController.containeeDelegate = self;
    
//    UIStoryboard *chatStoryboard = [UIStoryboard storyboardWithName:@"ChatScene" bundle:nil];
//    STConversationsListViewController *messagesViewController = (STConversationsListViewController *)[chatStoryboard instantiateViewControllerWithIdentifier:@"STConversationsListViewController"];
//    messagesViewController.containeeDelegate = self;
    
    _viewControllers = @[notifController];
    
    UIColor * backgroundColor = [UIColor colorWithRed:46.0f/255.0f green:47.0f/255.0f blue:50.0f/255.0f alpha:1];
    self.view.backgroundColor = backgroundColor;
    self.childContainer.backgroundColor = backgroundColor;
    
    _pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    _pageController.view.backgroundColor = backgroundColor;
    _pageController.view.tintColor = backgroundColor;
    
    _pageController.delegate = self;
    _pageController.dataSource = self;
    
    [_pageController setViewControllers:@[_viewControllers.firstObject] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    _pageController.view.frame = self.childContainer.bounds;
    [self.childContainer addSubview:_pageController.view];
    [self addChildViewController:_pageController];
    
    [_pageController setViewControllers:@[_viewControllers[0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];

    [self.navigationController setNavigationBarHidden:YES];
//    _customSegment = [STCustomSegment customSegmentWithDelegate:self];
//    [_customSegment configureSegmentWithDelegate:self];
//    CGRect rect = _customSegment.frame;
//    rect.origin.x = 0.f;
//    rect.origin.y = 0.f;
//    rect.size.width = self.topContainerView.frame.size.width;
//    rect.size.height = self.topContainerView.frame.size.height;
//    _customSegment.frame = rect;
//    _customSegment.translatesAutoresizingMaskIntoConstraints = YES;
//    [self.topContainerView addSubview:_customSegment];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToNotifications:) name:STNotificationSelectNotificationsScreen object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToNotifications:) name:STNotificationSelectChatScreen object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationsShouldBeReloaded:) name:STNotificationsShouldBeReloaded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(badgeNotificationChanged:) name:kBadgeCountChangedNotification object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notifications

- (void)notificationsShouldBeReloaded:(NSNotification *)notif{
    [self goToNotifications:nil];
    
    STNotificationsViewController *notifVc = (STNotificationsViewController *)[_viewControllers firstObject];
    [notifVc getNotificationsFromServer];
}

- (void)badgeNotificationChanged:(NSNotification *)notification{
    
    NSNumber *unreadMessages = notification.userInfo[kBadgeCountMessagesKey];
//    NSNumber *unreadNotifications = notification.userInfo[kBadgeCountNotificationsKey];
    
    if (unreadMessages == nil) {
        [self goToNotifications:nil];
        
        STNotificationsViewController *notifVc = (STNotificationsViewController *)[_viewControllers firstObject];
        [notifVc getNotificationsFromServer];
    }
//    else
//    {
//        [self goToMessages:nil];
//    }
    
}

@end

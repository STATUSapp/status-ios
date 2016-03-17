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

@interface STNotificationAndChatContainerViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *childContainer;
@property (weak, nonatomic) IBOutlet UIView *pageIndicatorView;
@property (weak, nonatomic) IBOutlet UIButton *btnNotifications;
@property (weak, nonatomic) IBOutlet UIButton *btnMessages;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pageIndicatorLeading;

@property (strong, nonatomic) UIPageViewController * pageController;
@property (strong, nonatomic) NSArray<UIViewController *> * viewControllers;

@property (strong, nonatomic) UIViewController * lastReturnedViewController;

@end

@implementation STNotificationAndChatContainerViewController

+ (instancetype)newController {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"ChatScene" bundle:[NSBundle mainBundle]];
    return [storyboard instantiateViewControllerWithIdentifier:@"STNotificationAndChatContainerViewController"];
}


#pragma mark - IBActions

- (IBAction)goToMessages:(id)sender {
    [self setControllerAndIndicatorViewForIndex:1];
    [self messagesSelected];
}
- (IBAction)goToNotifications:(id)sender {
    [self setControllerAndIndicatorViewForIndex:0];
    [self notificationsSelected];
}

- (void)messagesSelected {
    _btnMessages.selected = YES;
    _btnNotifications.selected = NO;
}

- (void)notificationsSelected {
    _btnMessages.selected = NO;
    _btnNotifications.selected = YES;
}

- (void)setControllerAndIndicatorViewForIndex:(NSInteger)index {
    __weak STNotificationAndChatContainerViewController * weakSelf = self;
    
    NSInteger offset = [self offsetForIndex:index];
    
    NSInteger currentVCIndex = [_viewControllers indexOfObject:_pageController.viewControllers.lastObject];
    
    if (index == currentVCIndex) {
        return;
    }
    
    UIPageViewControllerNavigationDirection direction = index > currentVCIndex ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    
    [_pageController setViewControllers:@[_viewControllers[index]] direction:direction animated:YES completion:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.pageIndicatorLeading.constant =  offset;
            [UIView animateWithDuration:0.35 animations:^{
                [weakSelf.view layoutIfNeeded];
            }];
        });
    }];
}

- (NSInteger)offsetForIndex:(NSInteger)index {
    NSInteger offset = 0;
    
    switch (index) {
        case 0:
            offset = 20;
            break;
            
        case 1:
            offset = self.view.frame.size.width - 20 - self.pageIndicatorView.frame.size.width;
            break;
            
        default:
            offset = 0;
            break;
    }
    
    return offset;
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
        
        
        NSInteger currentVCIndex = [_viewControllers indexOfObject:pageViewController.viewControllers.lastObject];
        
        switch (currentVCIndex) {
            case 0:
                [self notificationsSelected];
                break;
            case 1:
                [self messagesSelected];
                break;
                
            default:
                break;
        }
        
        _pageIndicatorLeading.constant = [self offsetForIndex:currentVCIndex];
        
        [UIView animateWithDuration:0.35 animations:^{
            [self.view layoutIfNeeded];
        }];
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

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES];
    
    UIColor * backgroundColor = [UIColor colorWithRed:46.0f/255.0f green:47.0f/255.0f blue:50.0f/255.0f alpha:1];
    self.view.backgroundColor = backgroundColor;
    self.childContainer.backgroundColor = backgroundColor;
    
    UIStoryboard * mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    STNotificationsViewController *notifController = [mainStoryboard instantiateViewControllerWithIdentifier: @"notificationScene"];
    notifController.containeeDelegate = self;
    
    UIStoryboard *chatStoryboard = [UIStoryboard storyboardWithName:@"ChatScene" bundle:nil];
    STConversationsListViewController *messagesViewController = (STConversationsListViewController *)[chatStoryboard instantiateViewControllerWithIdentifier:@"STConversationsListViewController"];
    messagesViewController.containeeDelegate = self;
    
    _viewControllers = @[notifController, messagesViewController];
    
    _pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    _pageController.view.backgroundColor = backgroundColor;
    _pageController.view.tintColor = backgroundColor;
    
    _pageController.delegate = self;
    _pageController.dataSource = self;
    
    [_pageController setViewControllers:@[_viewControllers.firstObject] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self notificationsSelected];
    
    
    _pageController.view.frame = self.childContainer.bounds;
    [self.childContainer addSubview:_pageController.view];
    [self addChildViewController:_pageController];
    
}

@end

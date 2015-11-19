//
//  FriendsInviterViewController.m
//  Status
//
//  Created by Silviu Burlacu on 06/10/15.
//  Copyright © 2015 Andrus Cosmin. All rights reserved.
//

#import "STFriendsInviterViewController.h"
#import "STSMSEmailInviterViewController.h"
#import "STFacebookInviterViewController.h"
#import "STContactsManager.h"
#import "STSuggestionsViewController.h"
#import "STMenuController.h"

@interface STFriendsInviterViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, STInvitationsDelegate, STSuggestionsDelegate>

@property (weak, nonatomic) IBOutlet UIView *childContainer;
@property (weak, nonatomic) IBOutlet UIView *pageIndicatorView;
@property (weak, nonatomic) IBOutlet UIButton *btnFacebook;
@property (weak, nonatomic) IBOutlet UIButton *btnEmail;
@property (weak, nonatomic) IBOutlet UIButton *btnSMS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pageIndicatorLeading;

@property (strong, nonatomic) UIPageViewController * pageController;
@property (strong, nonatomic) NSArray<UIViewController *> * viewControllers;

@property (strong, nonatomic) UIViewController * lastReturnedViewController;


@end

@implementation STFriendsInviterViewController

#pragma mark - IBActions
- (IBAction)closeInviteFriends:(UIButton *)sender {
    STSuggestionsViewController * suggestionsVC = [STSuggestionsViewController instatiateWithDelegate:self andFollowTyep:STFollowTypeFriendsAndPeople];
    [self.navigationController pushViewController:suggestionsVC animated:true];
}

- (IBAction)goToSMSInviter:(id)sender {
    [self setControllerAndIndicatorViewForIndex:1];
}

- (void)setControllerAndIndicatorViewForIndex:(NSInteger)index {
    __weak STFriendsInviterViewController * weakSelf = self;
    
    NSInteger offset = [self offsetForIndex:index];
    
    [_pageController setViewControllers:@[_viewControllers[index]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
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
            offset = (self.view.frame.size.width - self.pageIndicatorView.frame.size.width) / 2;
            break;
            
        case 2:
            offset = self.view.frame.size.width - 20 - self.pageIndicatorView.frame.size.width;
            break;
            
        default:
            offset = 0;
            break;
    }
    
    return offset;
}

- (IBAction)goToEmailInviter:(id)sender {
    
    [self setControllerAndIndicatorViewForIndex:2];

}
- (IBAction)goToFacebookInviter:(id)sender {
    
    [self setControllerAndIndicatorViewForIndex:0];
}


#pragma mark - STSuggestionsDelegate

- (void)userDidEndApplyingSugegstions {
    [[STMenuController sharedInstance] goHome];
}

#pragma mark - STInvitationsDelegate

- (void)userDidInviteSelectionsFromController:(STSMSEmailInviterViewController *)controller {
    NSInteger controllerIndex = [_viewControllers indexOfObject:controller];
    
    if (controllerIndex == NSNotFound) {
        return;
    }
    
    if (controllerIndex == _viewControllers.count - 1) {
        STSuggestionsViewController * suggestionsVC = [STSuggestionsViewController instatiateWithDelegate:self andFollowTyep:STFollowTypeFriendsAndPeople];
        [self.navigationController pushViewController:suggestionsVC animated:true];
    } else {
        [_pageController setViewControllers:@[[_viewControllers objectAtIndex:controllerIndex + 1]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.pageIndicatorLeading.constant =  (controllerIndex + 1) * self.pageIndicatorView.frame.size.width;
            [UIView animateWithDuration:0.35 animations:^{
                [self.view layoutIfNeeded];
            }];
        });

    }
}

- (void)inviterEndedScrolling {
    for (UIView * view in _pageController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            [((UIScrollView *)view) setScrollEnabled:YES];
        }
    }
}

- (void)inviterStartedScrolling {
    for (UIView * view in _pageController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            [((UIScrollView *)view) setScrollEnabled:NO];
        }
    }
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
        _pageIndicatorLeading.constant = [self offsetForIndex:currentVCIndex];
        
        [UIView animateWithDuration:0.35 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    
    for (UIViewController * controller in _viewControllers) {
        if ([controller respondsToSelector:@selector(parentEndedScrolling)]) {
            [controller performSelector:@selector(parentEndedScrolling) withObject:nil];
        }
    }
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    for (UIViewController * controller in _viewControllers) {
        if ([controller respondsToSelector:@selector(parentStartedScrolling)]) {
            [controller performSelector:@selector(parentStartedScrolling) withObject:nil];
        }
    }
}


#pragma mark - Lifecycle

+ (STFriendsInviterViewController *)newController {
    UIViewController * friendsInviter = [[UIStoryboard storyboardWithName:@"Invite" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:NSStringFromClass([STFriendsInviterViewController class])];
    return (STFriendsInviterViewController *)friendsInviter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES];
    
    UIColor * backgroundColor = [UIColor colorWithRed:46.0f/255.0f green:47.0f/255.0f blue:50.0f/255.0f alpha:1];
    self.view.backgroundColor = backgroundColor;
    self.childContainer.backgroundColor = backgroundColor;
    _viewControllers = @[[STFacebookInviterViewController newController],
                         [STSMSEmailInviterViewController newControllerWithInviteType:STInviteTypeSMS delegate:self],
                         [STSMSEmailInviterViewController newControllerWithInviteType:STInviteTypeEmail delegate:self]];
    
    [STContactsManager sharedInstance];
    
    _pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    _pageController.view.backgroundColor = backgroundColor;
    _pageController.view.tintColor = backgroundColor;

    _pageController.delegate = self;
    _pageController.dataSource = self;
    
    [_pageController setViewControllers:@[_viewControllers.firstObject] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    _pageController.view.frame = self.childContainer.bounds;
    [self.childContainer addSubview:_pageController.view];
    [self addChildViewController:_pageController];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    
    
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

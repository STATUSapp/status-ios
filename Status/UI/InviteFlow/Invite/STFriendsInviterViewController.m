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

- (void)smsSelected {
    _btnEmail.selected = NO;
    _btnSMS.selected = YES;
    _btnFacebook.selected = NO;
}

- (void)facebookSelected {
    _btnEmail.selected = NO;
    _btnSMS.selected = NO;
    _btnFacebook.selected = YES;
}

- (void)emailSelected {
    _btnEmail.selected = YES;
    _btnSMS.selected = NO;
    _btnFacebook.selected = NO;
}

- (IBAction)closeInviteFriends:(UIButton *)sender {
    STSuggestionsViewController * suggestionsVC = [STSuggestionsViewController instatiateWithDelegate:self andFollowTyep:STFollowTypeFriendsAndPeople];
    [self.navigationController pushViewController:suggestionsVC animated:true];
}

- (IBAction)goToSMSInviter:(id)sender {
    [self setControllerAndIndicatorViewForIndex:1];
    [self smsSelected];
}

- (void)setControllerAndIndicatorViewForIndex:(NSInteger)index {
    __weak STFriendsInviterViewController * weakSelf = self;
    
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
    [self emailSelected];

}
- (IBAction)goToFacebookInviter:(id)sender {
    
    [self setControllerAndIndicatorViewForIndex:0];
    [self facebookSelected];
}


#pragma mark - STSuggestionsDelegate

- (void)userDidEndApplyingSugegstions {
    [self.navigationController popToRootViewControllerAnimated:YES];
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
        
        switch (currentVCIndex) {
            case 0:
                [self facebookSelected];
                break;
            case 1:
                [self smsSelected];
                break;
            case 2:
                [self emailSelected];
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
    
    [[CoreManager contactsService] updateContactsList];
    
    UIColor * backgroundColor = [UIColor colorWithRed:46.0f/255.0f green:47.0f/255.0f blue:50.0f/255.0f alpha:1];
    self.view.backgroundColor = backgroundColor;
    self.childContainer.backgroundColor = backgroundColor;
    _viewControllers = @[[STFacebookInviterViewController newController],
                         [STSMSEmailInviterViewController newControllerWithInviteType:STInviteTypeSMS delegate:self],
                         [STSMSEmailInviterViewController newControllerWithInviteType:STInviteTypeEmail delegate:self]];
        
    _pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    _pageController.view.backgroundColor = backgroundColor;
    _pageController.view.tintColor = backgroundColor;

    _pageController.delegate = self;
    _pageController.dataSource = self;
    
    [_pageController setViewControllers:@[_viewControllers.firstObject] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self facebookSelected];
    
    
    _pageController.view.frame = self.childContainer.bounds;
    [self.childContainer addSubview:_pageController.view];
    [self addChildViewController:_pageController];

}




@end

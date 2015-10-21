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

@interface STFriendsInviterViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *childContainer;
@property (weak, nonatomic) IBOutlet UIView *pageIndicatorView;
@property (weak, nonatomic) IBOutlet UIButton *btnFacebook;
@property (weak, nonatomic) IBOutlet UIButton *btnEmail;
@property (weak, nonatomic) IBOutlet UIButton *btnSMS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pageIndicatorLeading;

@property (strong, nonatomic) UIPageViewController * pageController;
@property (strong, nonatomic) NSMutableArray<UIViewController *> * viewControllers;

@property (strong, nonatomic) UIViewController * lastReturnedViewController;


@end

@implementation STFriendsInviterViewController

#pragma mark - IBActions

- (IBAction)goToSMSInviter:(id)sender {
    
    __weak STFriendsInviterViewController * weakSelf = self;
    
    NSInteger index = 1;
    
    [_pageController setViewControllers:@[_viewControllers[index]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.pageIndicatorLeading.constant =  index * weakSelf.pageIndicatorView.frame.size.width;
            [UIView animateWithDuration:0.35 animations:^{
                [weakSelf.view layoutIfNeeded];
            }];
        });
    }];
}

- (IBAction)goToEmailInviter:(id)sender {
    
    __weak STFriendsInviterViewController * weakSelf = self;
    
    NSInteger index = 2;
    
    [_pageController setViewControllers:@[_viewControllers[index]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.pageIndicatorLeading.constant =  index * weakSelf.pageIndicatorView.frame.size.width;
            [UIView animateWithDuration:0.35 animations:^{
                [weakSelf.view layoutIfNeeded];
            }];
        });
    }];}
- (IBAction)goToFacebookInviter:(id)sender {
    
    __weak STFriendsInviterViewController * weakSelf = self;
    
    NSInteger index = 0;
    
    [_pageController setViewControllers:@[_viewControllers[index]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.pageIndicatorLeading.constant =  index * weakSelf.pageIndicatorView.frame.size.width;
            [UIView animateWithDuration:0.35 animations:^{
                [weakSelf.view layoutIfNeeded];
            }];
        });
    }];}

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
        _pageIndicatorLeading.constant = currentVCIndex * _pageIndicatorView.frame.size.width;
        
        [UIView animateWithDuration:0.35 animations:^{
            [self.view layoutIfNeeded];
        }];
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

    _viewControllers = [NSMutableArray array];
    
    [STContactsManager sharedInstance];
    
    [_viewControllers addObject:[STFacebookInviterViewController newController]];
    
    for (int i = 0; i < 2; i++) {

        
        
        
        STSMSEmailInviterViewController * childController;
        
        switch (i) {
            case 0:
                childController = [STSMSEmailInviterViewController newControllerWithInviteType:STInviteTypeSMS delegate:nil];
                break;
            case 1:
                childController = [STSMSEmailInviterViewController newControllerWithInviteType:STInviteTypeEmail delegate:nil];
                break;
                
            default:
                childController.view.backgroundColor = [UIColor grayColor];
                break;
        }
        
        [_viewControllers addObject:childController];
    }

    _pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    _pageController.delegate = self;
    _pageController.dataSource = self;
    [_pageController setViewControllers:@[_viewControllers.firstObject] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    _pageController.view.frame = self.childContainer.bounds;
    [self.childContainer addSubview:_pageController.view];
    [self addChildViewController:_pageController];
    
    _childContainer.layer.borderWidth = 5;
    _childContainer.layer.borderColor = [UIColor purpleColor].CGColor;
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

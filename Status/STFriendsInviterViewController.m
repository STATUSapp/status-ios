//
//  FriendsInviterViewController.m
//  Status
//
//  Created by Silviu Burlacu on 06/10/15.
//  Copyright © 2015 Andrus Cosmin. All rights reserved.
//

#import "STFriendsInviterViewController.h"
#import "STSMSEmailInviterViewController.h"

@interface STFriendsInviterViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *childContainer;

@property (strong, nonatomic) UIPageViewController * pageController;
@property (strong, nonatomic) NSMutableArray<UIViewController *> * viewControllers;

@end

@implementation STFriendsInviterViewController


#pragma mark - UIPageViewController Delegate and Datasource


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger currentIndex = [_viewControllers indexOfObject:viewController];
    if (currentIndex + 1 < _viewControllers.count) {
        return _viewControllers[++currentIndex];
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSInteger currentIndex = [_viewControllers indexOfObject:viewController];
    if (currentIndex > 0) {
        return _viewControllers[--currentIndex];
    }
    return nil;
}


#pragma mark - Lifecycle

+ (STFriendsInviterViewController *)newController {
    UIViewController * friendsInviter = [[UIStoryboard storyboardWithName:@"Invite" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:NSStringFromClass([STFriendsInviterViewController class])];
    return (STFriendsInviterViewController *)friendsInviter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    for (int i = 0; i < 3; i++) {
        
        if (_viewControllers == nil) {
            _viewControllers = [NSMutableArray array];
        }
        
        STSMSEmailInviterViewController * childController = [[STSMSEmailInviterViewController alloc] init];
        
        switch (i) {
            case 0:
                childController.view.backgroundColor = [UIColor blueColor];
                break;
            case 1:
                childController.view.backgroundColor = [UIColor yellowColor];
                break;
            case 2:
                childController.view.backgroundColor = [UIColor redColor];
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

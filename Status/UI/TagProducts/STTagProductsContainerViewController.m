//
//  STTagProductsContainerViewController.m
//  Status
//
//  Created by Cosmin Andrus on 26/10/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STTagProductsContainerViewController.h"

NSString *const kSegueBarcode = @"SEGUE_BARCODE";
NSString *const kSegueMissing = @"SEGUE_MISSING";
NSString *const kSegueEmpty = @"SEGUE_EMPTY";
NSString *const kSegueCategories = @"SEGUE_CATEGORIES";
NSString *const kSegueProducts = @"SEGUE_PRODUCTS";
NSString *const kSegueManual = @"SEGUE_MANUAL";

@interface STTagProductsContainerViewController ()

@property (strong, nonatomic) NSString *currentSegueID;
@property (strong, nonatomic, readwrite) UIViewController *currentVC;

@end

@implementation STTagProductsContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self swapToSegue:kSegueEmpty];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)swapToSegue:(NSString *)segue{
    if (![segue isEqualToString:self.currentSegueID]) {
        self.currentSegueID = segue;
        [self performSegueWithIdentifier:segue sender:nil];
    }
}

#pragma mark - Navigation

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     if (![self.childViewControllers containsObject:segue.destinationViewController]) {
         [self addChildViewController:segue.destinationViewController];
         ((UIViewController *)segue.destinationViewController).view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
         [segue.destinationViewController didMoveToParentViewController:self];
     }
     [self swapFromViewController:self.currentVC
                 toViewController:segue.destinationViewController];
     self.currentVC = segue.destinationViewController;
 }

- (void)swapFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
{
    toViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    if (fromViewController) {
        [self transitionFromViewController:fromViewController
                          toViewController:toViewController
                                  duration:0.0
                                   options:UIViewAnimationOptionTransitionNone
                                animations:nil
                                completion:^(BOOL finished) {
                                    [self.view addSubview:toViewController.view];
                                    [fromViewController removeFromParentViewController];
                                    [toViewController didMoveToParentViewController:self];
                                }];
    }
    else{
        [self.view addSubview:toViewController.view];
        [toViewController didMoveToParentViewController:self];
    }
}


@end

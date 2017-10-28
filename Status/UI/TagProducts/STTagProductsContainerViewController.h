//
//  STTagProductsContainerViewController.h
//  Status
//
//  Created by Cosmin Andrus on 26/10/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kSegueBarcode;
extern NSString *const kSegueMissing;
extern NSString *const kSegueEmpty;
extern NSString *const kSegueCategories;
extern NSString *const kSegueProducts;
extern NSString *const kSegueManual;

@interface STTagProductsContainerViewController : UIViewController
@property (strong, nonatomic, readonly) UIViewController *currentVC;

-(void)swapToSegue:(NSString *)segue;

@end

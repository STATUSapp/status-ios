//
//  UIAlertController+Additions.h
//  Status
//
//  Created by test on 07/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Additions)

+ (void)presentAlertControllerInViewController:(UIViewController *)vc title:(NSString *)title message:(NSString *)message andDismissButtonTitle:(NSString *)btnTitle;

@end

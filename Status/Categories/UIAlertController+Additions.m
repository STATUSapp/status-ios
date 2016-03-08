//
//  UIAlertController+Additions.m
//  Status
//
//  Created by test on 07/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "UIAlertController+Additions.h"

@implementation UIAlertController (Additions)

+ (void)presentAlertControllerInViewController:(UIViewController *)vc title:(NSString *)title message:(NSString *)message andDismissButtonTitle:(NSString *)btnTitle {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * action = [UIAlertAction actionWithTitle:btnTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    [alertController addAction:action];
    [vc presentViewController:alertController animated:YES completion:nil];
}

@end

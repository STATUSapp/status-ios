//
//  UIViewController+Snapshot.m
//  Status
//
//  Created by Andrus Cosmin on 17/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "UIViewController+Snapshot.h"
#import "UIImage+ImageEffects.h"

@implementation UIViewController (Snapshot)
- (UIImage *)blurScreen{
    UIImage * imageFromCurrentView = [UIViewController snapshotForViewController:self];
    return [imageFromCurrentView applyDarkEffect];
}

+ (UIImage *)snapshotForViewController:(UIViewController *)vc{
    UIGraphicsBeginImageContextWithOptions(vc.view.bounds.size, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [vc.view.layer renderInContext:context];
    UIImage *imageFromCurrentView = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageFromCurrentView;
}

@end

//
//  UIView+AnimatedZoom.m
//  Status
//
//  Created by Cosmin Andrus on 29/04/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "UIView+AnimatedZoom.h"

@implementation UIView (AnimatedZoom)

-(void)animateZoom:(CGFloat)maxZoomFactor{
    __weak UIView *weakSelf = self;
    [UIView animateWithDuration:0.25
                          delay:0.0
         usingSpringWithDamping:0.0
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         __strong UIView *strongSelf = weakSelf;
                         strongSelf.transform = CGAffineTransformMakeScale(maxZoomFactor, maxZoomFactor);
    } completion:^(BOOL finished) {
        __strong UIView *strongSelf = weakSelf;
        [UIView animateWithDuration:0.5f animations:^{
            strongSelf.transform = CGAffineTransformMakeScale(1.0,1.0);
        } completion:nil];
    }];
}

@end

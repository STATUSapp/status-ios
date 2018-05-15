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
    [UIView animateWithDuration:0.25
                          delay:0.0
         usingSpringWithDamping:0.0
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.transform = CGAffineTransformMakeScale(maxZoomFactor, maxZoomFactor);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5f animations:^{
            self.transform = CGAffineTransformMakeScale(1.0,1.0);
        } completion:nil];
    }];
}

@end

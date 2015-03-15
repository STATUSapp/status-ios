//
//  UIImageView+TouchesEffects.m
//  Status
//
//  Created by Silviu on 22/05/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "UIImageView+TouchesEffects.h"

@implementation UIImageView (TouchesEffects)

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.alpha = 0.5;
    [self setNeedsLayout];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.alpha = 1;
    [self setNeedsLayout];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.alpha = 1;
    [self setNeedsLayout];
}

@end

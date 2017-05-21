//
//  UIImageView+Mask.m
//  Status
//
//  Created by Andrus Cosmin on 29/05/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "UIImageView+Mask.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIImageView (Mask)

-(void)maskImage:(UIImage *)image{
    self.image = image;
    CGRect rect = self.frame;
    self.layer.cornerRadius = rect.size.width/2.f;
    self.layer.backgroundColor = [[UIColor clearColor] CGColor];
    self.layer.masksToBounds = YES;
}

@end

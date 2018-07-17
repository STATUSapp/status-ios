//
//  UIImageView+Mask.m
//  Status
//
//  Created by Andrus Cosmin on 29/05/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "UIImageView+Mask.h"
#import <QuartzCore/QuartzCore.h>
#import "STTopBase.h"

@implementation UIImageView (Mask)

#pragma mark - Public
-(void)maskImage:(UIImage *)image{
    self.image = image;
    CGRect rect = self.frame;
    self.layer.cornerRadius = rect.size.width/2.f;
    self.layer.backgroundColor = [[UIColor clearColor] CGColor];
    self.layer.masksToBounds = YES;
}

-(void)topOneMask{
    UIColor *borderColor = [STTopBase topOneBorderColor];
    CGFloat borderWidth = [STTopBase topOneBorderWidth];
    [self addBorderWithColor:borderColor
                 borderWidth:borderWidth];
}

-(void)topTwoMask{
    UIColor *borderColor = [STTopBase topTwoBorderColor];
    CGFloat borderWidth = [STTopBase topTwoBorderWidth];
    [self addBorderWithColor:borderColor
                 borderWidth:borderWidth];

}

-(void)topThreeMask{
    UIColor *borderColor = [STTopBase topThreeBorderColor];
    CGFloat borderWidth = [STTopBase topThreeBorderWidth];
    [self addBorderWithColor:borderColor
                 borderWidth:borderWidth];

}

#pragma mark - Private

- (void)addBorderWithColor:(UIColor *)borderColor
               borderWidth:(CGFloat)borderWidth {
    CGRect rect = self.frame;
    self.layer.cornerRadius = rect.size.width/2.f;
    self.layer.backgroundColor = [[UIColor clearColor] CGColor];
    self.layer.borderColor = [borderColor CGColor];
    self.layer.borderWidth = borderWidth;
    self.layer.masksToBounds = YES;
}

@end

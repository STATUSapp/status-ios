//
//  UIImage+Assets.m
//  Status
//
//  Created by Cosmin Andrus on 08/01/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "UIImage+Assets.h"

@implementation UIImage (Assets)

+(UIImage *)backButtonImage{
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 0, 0);
    UIImage *image = [UIImage imageNamed:@"icons8-back"];
    UIImage *alignedImage = [image imageWithAlignmentRectInsets:insets];
    return alignedImage;

}

@end

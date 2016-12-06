//
//  STUIHelper.m
//  Status
//
//  Created by Cosmin Home on 29/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STUIHelper.h"

@implementation STUIHelper

+ (UIImage *)splashImageWithLogo:(BOOL)withLogo{
    NSString *imageName = @"splash1202x2208";
    if ([[UIScreen mainScreen] scale] == 2.0) {
        
        if([UIScreen mainScreen].bounds.size.height == 667){
            // iPhone retina-4.7 inch(iPhone 6)
            imageName = @"splash750x1334";
        }
        else if([UIScreen mainScreen].bounds.size.height == 568){
            // iPhone retina-4 inch(iPhone 5 or 5s)
            imageName = @"splash640x1136";
        }
        else{
            // iPhone retina-3.5 inch(iPhone 4s)
            imageName = @"splash640x960";
        }
    }
    else if ([[UIScreen mainScreen] scale] == 3.0)
    {
        //if you want to detect the iPhone 6+ only
        if([UIScreen mainScreen].bounds.size.height == 736.0){
            //iPhone retina-5.5 inch screen(iPhone 6 plus)
            imageName = @"splash1202x2208";
        }
    }
    
    if (withLogo == YES) {
        imageName = [imageName stringByAppendingString:@"-logo"];
    }
    return [UIImage imageNamed:imageName];
}

@end

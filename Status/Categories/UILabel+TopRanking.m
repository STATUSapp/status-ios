//
//  UILabel+TopRanking.m
//  Status
//
//  Created by Cosmin Andrus on 15/07/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "UILabel+TopRanking.h"
#import <QuartzCore/QuartzCore.h>
#import "STTopBase.h"

CGFloat const kBorderRadius = 0.04;
CGFloat const kFontSizeProportion = 0.47;

@implementation UILabel (TopRanking)

- (void)configureWithTop:(STTopBase *)top{
    CGRect rect = self.frame;
    NSString *rankString = [top rankString];
    UIColor *topColor = [top topColor];
    CGFloat fontSize = rect.size.width * kFontSizeProportion;
    fontSize = fontSize - (CGFloat)rankString.length;
    UIFont *font = [UIFont fontWithName:self.font.fontName
                                   size:fontSize];
    self.font = font;
    self.text = rankString;
    self.textColor = topColor;
    
    self.layer.cornerRadius = rect.size.width/2.f;
    self.layer.backgroundColor = [[UIColor clearColor] CGColor];
    
    self.layer.borderColor = [topColor CGColor];
    self.layer.borderWidth = kBorderRadius * self.frame.size.width;
    
    self.layer.masksToBounds = YES;
    
}

@end

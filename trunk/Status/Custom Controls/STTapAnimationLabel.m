//
//  STTapAnimationLabel.m
//  Status
//
//  Created by Silviu on 23/05/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STTapAnimationLabel.h"

@implementation STTapAnimationLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

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

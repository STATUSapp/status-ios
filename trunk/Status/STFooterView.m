//
//  STFooterView.m
//  Status
//
//  Created by Cosmin Andrus on 4/15/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STFooterView.h"

@implementation STFooterView

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

-(NSString *)reuseIdentifier{
    return @"footerView";
}

@end

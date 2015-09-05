//
//  STFBAdCell.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 27/07/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STFBAdCell.h"
#import "STSmallFlowCell.h"

@implementation STFBAdCell
-(void)configureCellWithFBNativeAdd:(FBNativeAd *)nativeAd{
    CGRect rect = self.contentView.frame;
    rect.size = [STSmallFlowCell cellSize];
    self.contentView.frame = rect;

    _adTitle.text = [nativeAd.title uppercaseString];
    _actionLabel.text = [nativeAd.callToAction uppercaseString];
    [nativeAd.coverImage loadImageAsyncWithBlock:^(UIImage *image) {
        _adImage.image = image;
    }];
}

-(void)setHighlighted:(BOOL)highlighted{
    if (highlighted == YES) {
        _selectedImage.hidden = NO;
    }
    else
    {
        _selectedImage.hidden = YES;
    }
}
@end

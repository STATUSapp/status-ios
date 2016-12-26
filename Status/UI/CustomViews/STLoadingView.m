//
//  STLoadingView.m
//  Status
//
//  Created by Cosmin Andrus on 26/12/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STLoadingView.h"
#import "DGActivityIndicatorView.h"

@implementation STLoadingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (STLoadingView *)loadingViewWithSize:(CGSize)size{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"STLoadingView"
                                                   owner:nil
                                                 options:nil];
    STLoadingView *customLoading = (STLoadingView *)[views firstObject];
    [customLoading configureWithSize:size];
    return customLoading;

}

-(void)configureWithSize:(CGSize)size{
    CGRect rect = self.frame;
    rect.size = size;
    self.frame = rect;
    
    CGFloat activityIndicatorWidth = 50.f;
    CGFloat activityIndicatorHeight = 50.f;
    
    CGFloat activityIndicatorOriginX = roundf((size.width - activityIndicatorWidth) / 2.f);
    CGFloat activityIndicatorOriginY = roundf((size.height - activityIndicatorHeight) / 2.f);

    DGActivityIndicatorView *activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeThreeDots tintColor:[UIColor blackColor] size:44.0f];
    activityIndicatorView.frame = CGRectMake(activityIndicatorOriginX, activityIndicatorOriginY, activityIndicatorWidth, activityIndicatorHeight);
    [self addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];

}

@end

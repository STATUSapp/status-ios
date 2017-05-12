//
//  STTagCustomView.m
//  Status
//
//  Created by Cosmin Andrus on 11/05/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STTagCustomView.h"

@interface STTagCustomView ()

@property (nonatomic, strong) IBOutlet UIButton *topButton;
@property (nonatomic, strong) IBOutlet UIButton *bottomButton;

@end

@implementation STTagCustomView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"Touches Began");
    _topButton.highlighted = _bottomButton.highlighted = YES;
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"Touches Ended");
    if (_delegate && [_delegate respondsToSelector:@selector(customViewWasTapped:)]) {
        [_delegate customViewWasTapped:self];
    }
}

-(void)setViewSelected:(BOOL)selected{
    _topButton.highlighted = _bottomButton.highlighted = NO;
    _topButton.highlighted = selected;
    _bottomButton.highlighted = selected;
}

@end

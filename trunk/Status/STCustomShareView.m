//
//  STCustomShareView.m
//  Status
//
//  Created by Andrus Cosmin on 04/03/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STCustomShareView.h"

CGFloat const kDefaultButtonHeight = 50;

@interface STCustomShareView()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrMoveScaleHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrDeleteHeight;
@property (weak, nonatomic) IBOutlet UIImageView *lineDelete;
@property (weak, nonatomic) IBOutlet UIImageView *lineMoveAndScale;

@end

@implementation STCustomShareView

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

-(void) setUpForThreeButtons:(BOOL)isThree{

    _constrDeleteHeight.constant = isThree ? 0 : kDefaultButtonHeight;
    _constrMoveScaleHeight.constant = isThree ? 0 : kDefaultButtonHeight;
    _deletaBtn.hidden = isThree;
    _moveScaleBtn.hidden = isThree;
    _lineDelete.hidden = isThree;
    _lineMoveAndScale.hidden = isThree;

}

-(void) setForDissmiss:(BOOL) isDissmissed{

    for (UIView * view in self.subviews) {
        view.alpha = isDissmissed ? 1 : 0;
        view.alpha = isDissmissed ? 0 : 1;
    }
}

@end

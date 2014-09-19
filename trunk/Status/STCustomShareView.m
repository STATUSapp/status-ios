//
//  STCustomShareView.m
//  Status
//
//  Created by Andrus Cosmin on 04/03/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STCustomShareView.h"
float const k3Btnheight = 170.f;
float const k5Btnheight = 299.f;
float const k3BtnFbOffset = -3.f;
float const k3BtnSaveOffset = -53.f;
float const k5BtnFbOffset = -31.f;
float const k5BtnSaveOffset = -81.f;

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
    self.customHeightConstraint.constant = (isThree==TRUE)?k3Btnheight:k5Btnheight;
    self.background.image = [UIImage imageNamed:(isThree==TRUE)?@"share background 3 buttons":@"share background 5 buttons good3"];
    self.deletaBtn.hidden = isThree;
    self.moveScaleBtn.hidden = isThree;
    self.fbTopConstraint.constant = isThree==TRUE?k3BtnFbOffset:k5BtnFbOffset;
    self.saveTopConstraint.constant = isThree == TRUE?k3BtnSaveOffset:k5BtnSaveOffset;
}

-(void) setForDissmiss:(BOOL) isDissmissed{
    //TODO: remove this magic numbers
    self.bubbleImgContraint.constant = isDissmissed==TRUE?-290:80;
}

@end

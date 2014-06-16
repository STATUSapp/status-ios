//
//  STCustomShareView.m
//  Status
//
//  Created by Andrus Cosmin on 04/03/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STCustomShareView.h"
float const k3Btnheight = 170.f;
float const k4Btnheight = 227.f;
float const k3BtnFbOffset = -3.f;
float const k3BtnSaveOffset = -53.f;
float const k4BtnFbOffset = -11.f;
float const k4BtnSaveOffset = -61.f;

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
    self.customHeightConstraint.constant = (isThree==TRUE)?k3Btnheight:k4Btnheight;
    self.background.image = [UIImage imageNamed:(isThree==TRUE)?@"share background 3 buttons":@"share background 4 buttons"];
    self.deletaBtn.hidden = isThree;
    self.fbTopConstraint.constant = isThree==TRUE?k3BtnFbOffset:k4BtnFbOffset;
    self.saveTopConstraint.constant = isThree == TRUE?k3BtnSaveOffset:k4BtnSaveOffset;
}

-(void) setForDissmiss:(BOOL) isDissmissed{
    self.bubbleImgContraint.constant = isDissmissed==TRUE?-200:80;
}

@end

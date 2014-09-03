//
//  STCustomShareView.h
//  Status
//
//  Created by Andrus Cosmin on 04/03/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STCustomShareView : UIView
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *customHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UIButton *deletaBtn;
@property (weak, nonatomic) IBOutlet UIButton *moveScaleBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fbTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubbleImgContraint;
@property (weak, nonatomic) IBOutlet UIView *shadowView;

-(void) setUpForThreeButtons:(BOOL)isThree;
-(void) setForDissmiss:(BOOL) isDissmissed;
@end

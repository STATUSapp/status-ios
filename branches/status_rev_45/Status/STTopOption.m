//
//  STTopOption.m
//  Status
//
//  Created by Andrus Cosmin on 09/03/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STTopOption.h"
#import <FacebookSDK/FacebookSDK.h>
#import "STFacebookController.h"
#import "STImageCacheController.h"

@implementation STTopOption

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) initForLogout{
    
    FBLoginView *loginBtn = [STFacebookController sharedInstance].loginButton;
    [self addSubview:loginBtn];
    NSLayoutConstraint *bottomConstraint =[NSLayoutConstraint
                                           constraintWithItem:loginBtn
                                           attribute:NSLayoutAttributeBottom
                                           relatedBy:NSLayoutRelationEqual
                                           toItem:self
                                           attribute:NSLayoutAttributeBottom
                                           multiplier:1.f
                                           constant:-22];
    
    NSLayoutConstraint *allignCenter = [NSLayoutConstraint
                                        constraintWithItem:loginBtn
                                        attribute:NSLayoutAttributeCenterX
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                        attribute:NSLayoutAttributeCenterX
                                        multiplier:1.f
                                        constant:0];
    
    [self addConstraints:@[bottomConstraint,allignCenter]];

}

@end

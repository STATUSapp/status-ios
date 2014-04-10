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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void) initWithType:(STTopOptionType) type{
    if (type == STTopOptionTypeLogout) {
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
    else
    {
        self.actionButton.hidden = self.currentUserName.hidden = self.currentUserImg.hidden = FALSE;
        [self updateBasicInfo];
    }
    
}

-(void) updateBasicInfo{
    NSString *userName = [[STFacebookController sharedInstance] getUDValueForKey:USER_NAME];
    NSString *photoLink = [[STFacebookController sharedInstance] getUDValueForKey:PHOTO_LINK];

    __weak STTopOption *weakSelf = self;
    
    [[STImageCacheController sharedInstance] loadImageWithName:photoLink andCompletion:^(UIImage *img) {
        weakSelf.currentUserImg.image = img;
        weakSelf.currentUserName.text = userName;
                
    }];
    
    
}

@end

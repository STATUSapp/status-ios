//
//  STLoginView.h
//  Status
//
//  Created by Cosmin Andrus on 11/06/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSInteger const kLoginViewTag;

@protocol STLoginViewDelegate <NSObject>

- (void)loginViewDidSelectFacebook;
- (void)loginViewDidSelectInstagram;

@end

@interface STLoginView : UIView

+ (STLoginView *)loginViewWithDelegate:(id<STLoginViewDelegate>)delegate;
- (void)animateIn;
- (void)animateOut;
@end

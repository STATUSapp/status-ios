//
//  STTagCustomView.h
//  Status
//
//  Created by Cosmin Andrus on 11/05/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STTagCustomViewProtocol <NSObject>

-(void)customViewWasTapped:(UIView *)customView;

@end

@interface STTagCustomView : UIView

@property (weak, nonatomic) id<STTagCustomViewProtocol>delegate;

-(void)setViewSelected:(BOOL)selected;
@end

//
//  STMenuView.h
//  Status
//
//  Created by Cosmin Andrus on 16/09/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STMenuView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *blurBackground;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerYConstraint;
@property (weak, nonatomic) IBOutlet UIView *itemsView;
@property (weak, nonatomic) IBOutlet UILabel *notificationBadge;

@end

//
//  STSnackWithActionBar.m
//  Status
//
//  Created by Cosmin Andrus on 03/12/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STSnackWithActionBar.h"

@interface STSnackWithActionBar()

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@end

@implementation STSnackWithActionBar

+(STSnackWithActionBar *)snackBarWithActionWithOwner:(id)owner
                                           andAction:(SEL)action{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"STSnackWithActionBar" owner:owner options:nil];
    STSnackWithActionBar *actionBar = (STSnackWithActionBar *)[views firstObject];
    [actionBar.actionButton addTarget:owner
                               action:action
                     forControlEvents:UIControlEventTouchUpInside];
    return actionBar;
}

-(void)configureWithMessage:(NSString *)messageString
                  andAction:(NSString *)actionString{
    _messageLabel.text = messageString;
    [_actionButton setTitle:actionString forState:UIControlStateNormal];
    [_actionButton setTitle:actionString forState:UIControlStateHighlighted];
    [_actionButton setTitle:actionString forState:UIControlStateSelected];
}

@end

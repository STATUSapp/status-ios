//
//  STSnackBar.m
//  Status
//
//  Created by Cosmin Andrus on 27/06/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STSnackBar.h"

@interface STSnackBar ()

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation STSnackBar

+ (STSnackBar *)snackBarWithOwner:(id)owner{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"STSnackBar" owner:owner options:nil];
    
    return (STSnackBar *)[views firstObject];
}

-(void)configureWithMessage:(NSString *)message{
    _messageLabel.text = message;
}

@end

//
//  STSnackBarService.m
//  Status
//
//  Created by Cosmin Andrus on 27/06/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STSnackBarService.h"
#import "STSnackBar.h"
#import "STSnackBarBaseService+Subclass.h"

@interface STSnackBarService ()

@end

@implementation STSnackBarService

-(instancetype)init{
    self = [super init];
    if (self) {
        self.snackBar = [STSnackBar snackBarWithOwner:self];
    }
    return self;
}

-(void)showSnackBarWithMessage:(NSString *)message{
    self.snackBar.alpha = 1.f;
    [(STSnackBar *)self.snackBar configureWithMessage:message];
    if (!self.snackBarOnScreen) {
        CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        CGFloat statusBarWidth = [UIApplication sharedApplication].statusBarFrame.size.width;
        
        CGRect snackBarFrame = self.snackBar.frame;
        snackBarFrame.origin.y = statusBarHeight;
        snackBarFrame.size.width = statusBarWidth;
        [self.snackBar setFrame:snackBarFrame];
        
        [[UIApplication sharedApplication].keyWindow addSubview:self.snackBar];
    }
    [super setupTimer];
}

@end

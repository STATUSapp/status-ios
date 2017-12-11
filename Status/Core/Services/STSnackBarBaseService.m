//
//  STSnackBarBaseService.m
//  Status
//
//  Created by Cosmin Andrus on 10/12/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STSnackBarBaseService.h"
#import "STSnackBarBaseService+Subclass.h"

@interface STSnackBarBaseService ()

@end

@implementation STSnackBarBaseService

-(void)dealloc{
    [self.snackBar removeFromSuperview];
    [self.timer invalidate];
    _timer = nil;
    _snackBar = nil;
    _snackBarOnScreen = NO;
}

-(void)setupTimer{
    self.timer = [NSTimer  scheduledTimerWithTimeInterval:3.f target:self selector:@selector(snackBarTimer) userInfo:nil repeats:NO];
}

-(void)snackBarTimer{
    [self hideSnackBar];
}

-(void)hideSnackBar{
    __weak STSnackBarBaseService *weakSelf = self;
    [UIView animateWithDuration:0.33 animations:^{
        weakSelf.snackBar.alpha = 0.f;
    } completion:^(BOOL finished) {
        [weakSelf.snackBar removeFromSuperview];
        weakSelf.snackBar.alpha = 1.f;
    }];
}
@end

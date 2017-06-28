//
//  STSnackBarService.m
//  Status
//
//  Created by Cosmin Andrus on 27/06/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STSnackBarService.h"
#import "STSnackBar.h"

@interface STSnackBarService ()

@property (nonatomic, strong) STSnackBar *snackBar;
@property (nonatomic, assign) BOOL snackBarOnScreen;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation STSnackBarService

-(instancetype)init{
    self = [super init];
    if (self) {
        self.snackBar = [STSnackBar snackBarWithOwner:self];
    }
    return self;
}

-(void)dealloc{
    [self.snackBar removeFromSuperview];
    [self.timer invalidate];
    _timer = nil;
    _snackBar = nil;
    _snackBarOnScreen = NO;
}

-(void)showSnackBarWithMessage:(NSString *)message{
    _snackBar.alpha = 1.f;
    [_snackBar configureWithMessage:message];
    if (!_snackBarOnScreen) {
        CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        CGFloat statusBarWidth = [UIApplication sharedApplication].statusBarFrame.size.width;
        
        CGRect snackBarFrame = _snackBar.frame;
        snackBarFrame.origin.y = statusBarHeight;
        snackBarFrame.size.width = statusBarWidth;
        [_snackBar setFrame:snackBarFrame];
        
        [[UIApplication sharedApplication].keyWindow addSubview:_snackBar];
    }
    
    _timer = [NSTimer  scheduledTimerWithTimeInterval:3.f target:self selector:@selector(snackBarTimer) userInfo:nil repeats:NO];
}

-(void)snackBarTimer{
    __weak STSnackBarService *weakSelf = self;
    [UIView animateWithDuration:0.33 animations:^{
        weakSelf.snackBar.alpha = 0.f;
    } completion:^(BOOL finished) {
        [weakSelf.snackBar removeFromSuperview];
        weakSelf.snackBar.alpha = 1.f;
    }];
}

@end

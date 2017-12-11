//
//  STSnackBarWithActionService.m
//  Status
//
//  Created by Cosmin Andrus on 10/12/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STSnackBarWithActionService.h"
#import "STSnackWithActionBar.h"
#import "STSnackBarBaseService+Subclass.h"
#import "STLocalNotificationService.h"
#import "STNavigationService.h"
#import "STTabBarViewController.h"

@interface STSnackBarWithActionService ()

@property (nonatomic, assign) STSnackWithActionBarType type;

@end

@implementation STSnackBarWithActionService

-(instancetype)init{
    self = [super init];
    if (self) {
        self.snackBar = [STSnackWithActionBar snackBarWithActionWithOwner:self andAction:@selector(barActionTapped:)];
    }
    return self;
}

-(void)showSnackBarWithType:(STSnackWithActionBarType)type{
    self.type = type;
    [(STSnackWithActionBar *)self.snackBar configureWithMessage:[self message] andAction:[self action]];
    if (!self.snackBarOnScreen) {
        STTabBarViewController *tabBarVC = [STNavigationService appTabBar];
        CGRect tabBarFrame = tabBarVC.tabBar.frame;
        CGRect snackBarFrame = self.snackBar.frame;
        snackBarFrame.origin.y = tabBarFrame.origin.y-snackBarFrame.size.height;
        snackBarFrame.size.width = tabBarFrame.size.width;
        [self.snackBar setFrame:snackBarFrame];
        
        [[UIApplication sharedApplication].keyWindow addSubview:self.snackBar];
    }
    [super setupTimer];
}

-(NSString *)message{
    NSString *result;
    switch (self.type) {
        case STSnackWithActionBarTypeGuestMode:
            result = NSLocalizedString(@"You are in guest mode", nil);
            break;
            
        default:
            result = @"";
            break;
    }
    return result;
}

-(NSString *)action{
    NSString *result;
    switch (self.type) {
        case STSnackWithActionBarTypeGuestMode:
            result = NSLocalizedString(@"SIGN IN", nil);
            break;
            
        default:
            result = @"";
            break;
    }
    return result;
}
#pragma mark - UINotitidfications

-(void)barActionTapped:(id)sender{
    [self hideSnackBar];
    [[CoreManager localNotificationService] postNotificationName:kNotificationSnackBarAction object:nil userInfo:@{kNotificationSnackBarActionTypeKey:@(self.type)}];
}
@end

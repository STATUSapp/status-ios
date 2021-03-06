//
//  BadgeService.m
//  Status
//
//  Created by Andrus Cosmin on 30/05/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "BadgeService.h"
#import "STLocalNotificationService.h"
#import "STNavigationService.h"
#import "STGetNotificationsCountRequest.h"
#import "STUnseenPostsCountRequest.h"

static NSString * const kSTLastBadgeNumber = @"kSTLastBadgeNumber";
static NSTimeInterval const kRefreshTimerInterval = 120.f;

NSString *const kUnreadMessagesCountChangedNotification = @"kUnreadMessagesCountChangedNotification";
NSString *const kUnreadMessagesCountKey = @"kUnreadMessagesCountKey";


NSString * const kBadgeCountChangedNotification = @"kBadgeCountChangedNotification";
NSString * const kBadgeCountMessagesKey = @"kBadgeCountMessagesKey";
NSString * const kBadgeCountNotificationsKey = @"kBadgeCountNotificationsKey";

@interface BadgeService ()

@property (nonatomic, strong) NSNumber *unreadMessages;
@property (nonatomic, strong) NSNumber *unreadNotifications;
@property (nonatomic, strong) NSTimer *refreshTimer;

@end

@implementation BadgeService

-(instancetype)init{
    self = [super init];
    if (self) {
        [self loadBadgeNumber];
    }
    
    return self;
}

- (void)startTimer{
    _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:kRefreshTimerInterval target:self selector:@selector(timerScheduled:) userInfo:nil repeats:YES];
}

- (void)timerScheduled:(id)sender{
    [self checkForNotificationNumber];
}

- (void)startService{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unreadMessagesCountChanged:) name:kUnreadMessagesCountChangedNotification object:nil];
    [self startTimer];
    //manually trigger first time
    [self checkForNotificationNumber];
}

- (void)stopService{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_refreshTimer invalidate];
    _refreshTimer = nil;
}

- (void)setBadgeForMessages{
    [[CoreManager navigationService] setBadge:_unreadMessages.integerValue forTabAtIndex:STTabBarIndexActivity];
}
- (void)setBadgeForNotifications{
    [[CoreManager navigationService] setBadge:_unreadNotifications.integerValue forTabAtIndex:STTabBarIndexActivity];
}


- (void)adjustUnreadMessages:(NSInteger)messagesCountToBeAdded{
    _unreadMessages = @(_unreadMessages.integerValue + messagesCountToBeAdded);
    [[CoreManager localNotificationService] postNotificationName:kBadgeCountChangedNotification object:nil userInfo:@{kBadgeCountMessagesKey:_unreadMessages}];
//    [[CoreManager navigationService] showMessagesIconOnTabBar];
    [[CoreManager navigationService] setBadge:_unreadMessages.integerValue forTabAtIndex:STTabBarIndexActivity];
}

-(void)checkForNotificationNumber{
    __weak BadgeService *weakSelf = self;
    if ([CoreManager loggedIn] &&
        ![CoreManager isGuestUser]) {
        STRequestCompletionBlock completion = ^(id response, NSError *error){
            if ([response[@"status_code"] integerValue] ==STWebservicesSuccesCod) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong BadgeService *strongSelf = weakSelf;
                    strongSelf.unreadNotifications = response[@"count"];
                    [[CoreManager localNotificationService] postNotificationName:kBadgeCountChangedNotification object:nil userInfo:@{kBadgeCountNotificationsKey:strongSelf.unreadNotifications}];
                    [[CoreManager navigationService] showActivityIconOnTabBar];
                    [[CoreManager navigationService] setBadge:strongSelf.unreadNotifications.integerValue forTabAtIndex:STTabBarIndexActivity];


                });
            }
        };
        [STGetNotificationsCountRequest getNotificationsCountWithCompletion:completion failure:^(NSError *error) {
            NSLog(@"error received on get notifications count: %@", error);
        }];
    }
}

-(void)loadBadgeNumber{
    NSNumber *lastBadgeNumber = [[NSUserDefaults standardUserDefaults] valueForKey:kSTLastBadgeNumber];
    if (lastBadgeNumber !=nil) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:lastBadgeNumber.integerValue];
    }
    else
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

-(void)setApplicationBadge{
    NSInteger badgeNumber = _unreadNotifications.integerValue + _unreadMessages.integerValue;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber];
    [[NSUserDefaults standardUserDefaults] setValue:@(badgeNumber) forKey:kSTLastBadgeNumber];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

#pragma mark - Notifications handlers

-(void) unreadMessagesCountChanged:(NSNotification *)notification{
    _unreadMessages = notification.userInfo[kUnreadMessagesCountKey];
    
    [[CoreManager localNotificationService] postNotificationName:kBadgeCountChangedNotification object:nil userInfo:@{kBadgeCountMessagesKey:_unreadMessages}];
//    [[CoreManager navigationService] showMessagesIconOnTabBar];
    [[CoreManager navigationService] setBadge:_unreadMessages.integerValue forTabAtIndex:STTabBarIndexActivity];


}
@end

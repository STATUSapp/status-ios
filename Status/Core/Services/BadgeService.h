//
//  BadgeService.h
//  Status
//
//  Created by Andrus Cosmin on 30/05/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kBadgeCountChangedNotification ;
extern NSString * const kBadgeCountMessagesKey ;
extern NSString * const kBadgeCountNotificationsKey ;

extern NSString *const kUnreadMessagesCountChangedNotification ;
extern NSString *const kUnreadMessagesCountKey ;

@interface BadgeService : NSObject

- (void)startService;
- (void)stopService;
- (void)adjustUnreadMessages:(NSInteger)readMessages;
- (void)checkForNotificationNumber;
- (void)setBadgeForMessages;
- (void)setBadgeForNotifications;
@end

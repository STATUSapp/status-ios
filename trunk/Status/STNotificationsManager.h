//
//  STNotificationsManager.h
//  Status
//
//  Created by Cosmin Andrus on 09/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STNotificationsManager : NSObject
+ (STNotificationsManager *)sharedManager;

-(void)handleLastNotification;
-(void) handleNotification:(NSDictionary *) notif;
-(void)handleInAppNotification:(NSDictionary *)notification;
@end

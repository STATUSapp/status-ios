//
//  STNotificationsViewController.h
//  Status
//
//  Created by Cosmin Andrus on 3/5/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STNotificationAndChatContainerViewController.h"


@interface STNotificationsViewController : UIViewController;

@property (nonatomic, weak) id<STSideBySideContaineeDelegate> containeeDelegate;

-(void) getNotificationsFromServer;

- (void)containerEndedScrolling;
- (void)containerStartedScrolling;
@end

//
//  STNotificationsViewController.h
//  Status
//
//  Created by Cosmin Andrus on 3/5/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STNotificationAndChatContainerViewController.h"
#import "STSideBySideContaineeProtocol.h"
#import "STSideBySideContainerProtocol.h"

@interface STNotificationsViewController : UIViewController<STSideBySideContainerProtocol>;

@property (nonatomic, weak) id<STSideBySideContaineeProtocol> containeeDelegate;

-(void) getNotificationsFromServer;

@end

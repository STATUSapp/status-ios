//
//  STConversationsListViewController.h
//  Status
//
//  Created by Silviu on 01/06/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STNotificationAndChatContainerViewController.h"


@interface STConversationsListViewController : UIViewController

@property (nonatomic, weak) id<STSideBySideContaineeDelegate> containeeDelegate;

-(void)loadNewDataWithOffset:(BOOL)newOffset;

- (void)containerEndedScrolling;
- (void)containerStartedScrolling;


@end

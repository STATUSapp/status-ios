//
//  STConversationsListViewController.h
//  Status
//
//  Created by Silviu on 01/06/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STNotificationAndChatContainerViewController.h"
#import "STSideBySideContaineeProtocol.h"
#import "STSideBySideContainerProtocol.h"

@interface STConversationsListViewController : UIViewController<STSideBySideContainerProtocol>

@property (nonatomic, weak) id<STSideBySideContaineeProtocol> containeeDelegate;

-(void)loadNewDataWithOffset:(BOOL)newOffset;

@end

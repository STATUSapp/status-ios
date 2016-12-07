//
//  STNotificationAndChatContainerViewController.h
//  Status
//
//  Created by test on 08/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STSideBySideContaineeProtocol.h"

@interface STNotificationAndChatContainerViewController : UIViewController<STSideBySideContaineeProtocol>

+ (instancetype)newController;

@end

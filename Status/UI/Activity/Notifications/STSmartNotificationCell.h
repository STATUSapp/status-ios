//
//  STSmartNotificationCell.h
//  Status
//
//  Created by Cosmin Andrus on 10/27/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STNotificationBaseCell.h"

@class STNotificationObj;

@interface STSmartNotificationCell : STNotificationBaseCell
-(void)configureWithNotificationObject:(STNotificationObj *)notification;
@end

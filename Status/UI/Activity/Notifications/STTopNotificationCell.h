//
//  STTopNotificationCell.h
//  Status
//
//  Created by Cosmin Andrus on 05/08/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STNotificationBaseCell.h"

@class STNotificationObj;

@interface STTopNotificationCell : STNotificationBaseCell

-(void)configureWithNotificationObject:(STNotificationObj *)notificationObj;

@end

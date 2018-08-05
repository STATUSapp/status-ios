//
//  STNotificationCell.h
//  Status
//
//  Created by Cosmin Andrus on 3/5/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STNotificationBaseCell.h"
// a tap is in a STNotificationRegionTypeUserRelated area if it's on user name or it's profile picture
// a tap is in a STNotificationRegionTypePostRelated area if it's on post icon
typedef NS_ENUM(NSInteger, STNotificationRegionType){
    STNotificationRegionTypeUserRelated = 0,
    STNotificationRegionTypePostRelated
};

@class STNotificationObj;
@interface STNotificationCell : STNotificationBaseCell

- (STNotificationRegionType)regionForPointOfTap:(CGPoint)pointOfTap;
-(void)configureWithNotificationObject:(STNotificationObj *)notificationObj;

@end

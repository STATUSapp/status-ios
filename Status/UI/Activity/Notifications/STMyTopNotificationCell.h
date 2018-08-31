//
//  STMyTopNotificationCell.h
//  Status
//
//  Created by Cosmin Andrus on 30/08/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STNotificationBaseCell.h"

// a tap is in a STMyNotificationRegionTypeTopRelated area if it's on top logo or top text
// a tap is in a STMyNotificationRegionTypePostRelated area if it's on post icon
typedef NS_ENUM(NSInteger, STMyNotificationRegionType){
    STMyNotificationRegionTypeTopRelated = 0,
    STMyNotificationRegionTypePostRelated
};

@class STNotificationObj;

@interface STMyTopNotificationCell : STNotificationBaseCell
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rankPostImageView;

- (STMyNotificationRegionType)regionForPointOfTap:(CGPoint)pointOfTap;
-(void)configureWithNotificationObject:(STNotificationObj *)notificationObj;

@end

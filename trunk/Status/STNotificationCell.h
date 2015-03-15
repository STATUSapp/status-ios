//
//  STNotificationCell.h
//  Status
//
//  Created by Cosmin Andrus on 3/5/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STTapAnimationLabel.h"
#import "STNotificationBaseCell.h"
// a tap is in a STNotificationRegionTypeUserRelated area if it's on user name or it's profile picture
// a tap is in a STNotificationRegionTypePostRelated area if it's on post icon
typedef NS_ENUM(NSInteger, STNotificationRegionType){
    STNotificationRegionTypeUserRelated = 0,
    STNotificationRegionTypePostRelated
};

@interface STNotificationCell : STNotificationBaseCell
@property (weak, nonatomic) IBOutlet STTapAnimationLabel *messageLbl;
@property (weak, nonatomic) IBOutlet UIImageView *postImg;
@property (assign, nonatomic) BOOL isSeen;

- (STNotificationRegionType)regionForPointOfTap:(CGPoint)pointOfTap;

@end

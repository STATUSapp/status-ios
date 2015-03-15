//
//  STNotificationBaseCell.h
//  Status
//
//  Created by Cosmin Andrus on 10/27/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STNotificationBaseCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImg;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UIImageView *seenCircle;
@property (weak, nonatomic) IBOutlet UILabel *notificationTypeMessage;

@end

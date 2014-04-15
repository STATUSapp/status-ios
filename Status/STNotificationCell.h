//
//  STNotificationCell.h
//  Status
//
//  Created by Cosmin Andrus on 3/5/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STNotificationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImg;
@property (weak, nonatomic) IBOutlet UILabel *messageLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UIImageView *postImg;
@property (weak, nonatomic) IBOutlet UIImageView *seenCircle;
@property (weak, nonatomic) IBOutlet UILabel *notificationTypeMessage;

@end

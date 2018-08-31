//
//  STTopNotificationCell.m
//  Status
//
//  Created by Cosmin Andrus on 05/08/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STTopNotificationCell.h"
#import "STNotificationObj.h"

@implementation STTopNotificationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureWithNotificationObject:(STNotificationObj *)notificationObj{
    NSAttributedString *detailsString = [self detailsStringForFullMessage:notificationObj.message actorName:@"Top Best Dressed" notificationDate:notificationObj.date];
    self.messageLbl.attributedText = detailsString;
}

@end

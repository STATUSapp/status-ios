//
//  STSmartNotificationCell.m
//  Status
//
//  Created by Cosmin Andrus on 10/27/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STSmartNotificationCell.h"
#import "STNotificationObj.h"
#import "UIImageView+WebCache.h"

@implementation STSmartNotificationCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureWithNotificationObject:(STNotificationObj *)notification{
    NSString *postPhotoLink = notification.postPhotoUrl;
    if (postPhotoLink.length == 0) {
        self.userImg.image = [UIImage imageNamed:@"logo"];
    }
    else
        [self.userImg sd_setImageWithURL:[NSURL URLWithString:postPhotoLink]];
    if (notification.type == STNotificationTypeNewUserJoinsStatus) {
        NSString *string = [NSString stringWithFormat:@"%@ is on STATUS. Say hello :)", notification.userName];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
        UIFont *boldFont = [UIFont fontWithName:@"ProximaNova-Bold" size:15.f];
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                               boldFont, NSFontAttributeName,nil];
        
        [attributedString setAttributes:attrs range:NSMakeRange(0, [notification.userName length])];
        self.messageLbl.attributedText = attributedString;
    }
    else
        self.messageLbl.text = notification.message;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}
@end

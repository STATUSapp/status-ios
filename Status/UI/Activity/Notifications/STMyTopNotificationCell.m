//
//  STMyTopNotificationCell.m
//  Status
//
//  Created by Cosmin Andrus on 30/08/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STMyTopNotificationCell.h"
#import "STNotificationObj.h"
#import "UIImageView+TouchesEffects.h"
#import "UIImageView+WebCache.h"
#import "UILabel+TopRanking.h"

@implementation STMyTopNotificationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (STMyNotificationRegionType)regionForPointOfTap:(CGPoint)pointOfTap{
    
    if (CGRectContainsPoint(self.rankLabel.frame, pointOfTap)) {
        return STMyNotificationRegionTypeTopRelated;
    }
    
    if (CGRectContainsPoint(self.rankPostImageView.frame, pointOfTap)) {
        return STMyNotificationRegionTypePostRelated;
    }
    
    return STMyNotificationRegionTypeTopRelated;
}

-(void)configureWithNotificationObject:(STNotificationObj *)notificationObj{
    [self.rankPostImageView sd_setImageWithURL:[NSURL URLWithString:notificationObj.postPhotoUrl]];
    NSAttributedString *detailsString = [self detailsStringForFullMessage:notificationObj.message actorName:@"Top Best Dressed" notificationDate:notificationObj.date];
    self.messageLbl.attributedText = detailsString;
    [self.rankLabel configureWithTop:notificationObj.top];

}
@end

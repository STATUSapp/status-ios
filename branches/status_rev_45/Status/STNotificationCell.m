//
//  STNotificationCell.m
//  Status
//
//  Created by Cosmin Andrus on 3/5/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STNotificationCell.h"
#import "UIImageView+TouchesEffects.h"
@interface STNotificationCell()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationTextTrailingConstraint;
@end

@implementation STNotificationCell

- (STNotificationRegionType)regionForPointOfTap:(CGPoint)pointOfTap{
    
    if (CGRectContainsPoint(self.userImg.frame, pointOfTap)) {
        return STNotificationRegionTypeUserRelated;
    }
    
    if (CGRectContainsPoint(self.messageLbl.frame, pointOfTap)) {
        return STNotificationRegionTypeUserRelated;
    }
    
    return STNotificationRegionTypePostRelated;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(NSString *)reuseIdentifier{
    return @"notificationCell";
}

-(void)prepareForReuse{
    self.seenCircle.hidden = NO;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    // the notification label should extend if there is no photo on the right part of the cell
    
    if (self.postImg.image == nil) {
        self.notificationTextTrailingConstraint.constant = 54;
    } else {
        self.notificationTextTrailingConstraint.constant = 104;
    }
}

@end

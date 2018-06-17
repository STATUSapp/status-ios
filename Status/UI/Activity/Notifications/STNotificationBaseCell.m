//
//  STNotificationBaseCell.m
//  Status
//
//  Created by Cosmin Andrus on 10/27/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STNotificationBaseCell.h"
#import "UIImageView+WebCache.h"

@implementation STNotificationBaseCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)prepareForReuse{
    [super prepareForReuse];
    [_userImg sd_cancelCurrentAnimationImagesLoad];
}
@end

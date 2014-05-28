//
//  STBubbleCell.m
//  Status
//
//  Created by Cosmin Andrus on 5/28/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STBubbleCell.h"

@implementation STBubbleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(CGSize)sizeForText:(NSString *)message {
    CGRect labelRect = [message
                        boundingRectWithSize:CGSizeMake(185.f, CGFLOAT_MAX)
                        options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{
                                     NSFontAttributeName : [UIFont fontWithName:@"Helvetica Neue" size:16.f]
                                     }
                        context:nil];
    return labelRect.size;
}

+(float)cellHeightForText:(NSString *)message{
    CGSize size = [STBubbleCell sizeForText:message];
    return size.height + 30.f;
}

@end

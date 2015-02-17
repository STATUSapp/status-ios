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
    //fix a strange bug where the width is not right loaded
    CGRect rect = self.bounds;
    UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
    rect.size.width = mainWindow.bounds.size.width;
    self.bounds = rect;
    self.contentView.frame = rect;
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"TimestampView" owner:self options:nil] firstObject];
    self.revealableView = view;

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
                                     NSFontAttributeName : [UIFont fontWithName:@"ProximaNova-Regular" size:16.f]
                                     }
                        context:nil];
    return labelRect.size;
}

+(float)cellHeightForText:(NSString *)message{
    CGSize size = [STBubbleCell sizeForText:message];
    return size.height + 30.f;
}

+(CGSize)sizeForMessage:(Message *)message {
    CGRect labelRect = [message.message
                        boundingRectWithSize:CGSizeMake(185.f, CGFLOAT_MAX)
                        options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{
                                     NSFontAttributeName : [UIFont fontWithName:@"ProximaNova-Regular" size:16.f]
                                     }
                        context:nil];
    return labelRect.size;
}

+(float)cellHeightForMessage:(Message *)message{
    CGSize size = [STBubbleCell sizeForMessage:message];
    return size.height + 30.f;
}

@end

//
//  STMessageReceivedCell.m
//  Status
//
//  Created by Andrus Cosmin on 27/05/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STMessageReceivedCell.h"
#import "UIImageView+Mask.h"

@interface STMessageReceivedCell()

@property (weak, nonatomic) IBOutlet UIImageView *userPicture;
@property (weak, nonatomic) IBOutlet UIImageView *bubleImg;
@property (weak, nonatomic) IBOutlet UILabel *messageLbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubleWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *dateLbl;

@end

@implementation STMessageReceivedCell

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

-(void)configureCellWithMessage:(NSString *) message andUserImage:(UIImage *)img andDate:(NSString *)dateStr{
    
    CGSize labelSize = [STBubbleCell sizeForText:message];
    _messageWidthConstraint.constant = labelSize.width +1;
    _bubleWidthConstraint.constant = labelSize.width + 27;
    CGRect rect = _messageLbl.frame;
    rect.size = labelSize;
    _messageLbl.frame = rect;
    _messageLbl.text = message;
    [_userPicture maskImage:img];
    if (dateStr!=nil) {
        _dateLbl.text = dateStr;
    }
    else
        _dateLbl.text = @"";
}

-(void)configureCellWithMessage:(Message *) message andUserImage:(UIImage *)img{
    
    CGSize labelSize = [STBubbleCell sizeForMessage:message];
    _messageWidthConstraint.constant = labelSize.width +1;
    _bubleWidthConstraint.constant = labelSize.width + 27;
    CGRect rect = _messageLbl.frame;
    rect.size = labelSize;
    _messageLbl.frame = rect;
    _messageLbl.text = message.message;
    [_userPicture maskImage:img];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm a"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    _dateLbl.text = [dateFormatter stringFromDate:message.date];

}

@end

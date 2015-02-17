//
//  STMessageSendCell.m
//  Status
//
//  Created by Andrus Cosmin on 27/05/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STMessageSendCell.h"

@interface STMessageSendCell()
@property (weak, nonatomic) IBOutlet UIImageView *bubleImg;
@property (weak, nonatomic) IBOutlet UILabel *messageLbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubleWidthContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageWidthContraint;
@property (weak, nonatomic) IBOutlet UILabel *dateLbl;

@end

@implementation STMessageSendCell

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
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureCellWithMessage:(NSString *) message andDateStr:(NSString *) dateStr{
    
    CGSize labelSize = [STBubbleCell sizeForText:message];
    _messageWidthContraint.constant = labelSize.width + 1;
    _bubleWidthContraint.constant = labelSize.width + 30;
    CGRect rect = _messageLbl.frame;
    rect.size = labelSize;
    _messageLbl.frame = rect;
    _messageLbl.text = message;
    
    if (dateStr!=nil) {
        _dateLbl.text = dateStr;
    }
    else
        _dateLbl.text = @"";
}

-(void)configureCellWithMessage:(Message *) message{
    
    CGSize labelSize = [STBubbleCell sizeForMessage:message];
    _messageWidthContraint.constant = labelSize.width + 1;
    _bubleWidthContraint.constant = labelSize.width + 30;
    CGRect rect = _messageLbl.frame;
    rect.size = labelSize;
    _messageLbl.frame = rect;
    _messageLbl.text = message.message;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm a"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    UILabel *datelabel = (UILabel *)[self.revealableView viewWithTag:101];
    datelabel.text = [dateFormatter stringFromDate:message.date];
}

@end

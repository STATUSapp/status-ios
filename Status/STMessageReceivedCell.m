//
//  STMessageReceivedCell.m
//  Status
//
//  Created by Andrus Cosmin on 27/05/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STMessageReceivedCell.h"

@interface STMessageReceivedCell()

@property (weak, nonatomic) IBOutlet UIImageView *userPicture;
@property (weak, nonatomic) IBOutlet UIImageView *bubleImg;
@property (weak, nonatomic) IBOutlet UILabel *messageLbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubleWidthConstraint;

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

-(void)configureCellWithMessage:(NSString *) message{
    
    CGSize labelSize = [STBubbleCell sizeForText:message];
    _messageWidthConstraint.constant = labelSize.width;
    _bubleWidthConstraint.constant = labelSize.width + 27;
    CGRect rect = _messageLbl.frame;
    rect.size = labelSize;
    _messageLbl.frame = rect;
    _messageLbl.text = message;
}

@end

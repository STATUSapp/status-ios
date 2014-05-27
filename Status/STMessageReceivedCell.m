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

+ (CGSize)sizeForText:(NSString *)message {
    CGRect labelRect = [message
                        boundingRectWithSize:CGSizeMake(185.f, MAXFLOAT)
                        options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{
                                     NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:16.f]
                                     }
                        context:nil];
    return labelRect.size;
}

-(void)configureCellWithMessage:(NSString *) message{
    
    CGSize labelSize = [STMessageReceivedCell sizeForText:message];
    _messageWidthConstraint.constant = labelSize.width;
    _bubleWidthConstraint.constant = labelSize.width + 27;
    CGRect rect = _messageLbl.frame;
    rect.size = labelSize;
    _messageLbl.frame = rect;
    _messageLbl.text = message;
    NSLog(@"Message: %@", message);
    NSLog(@"Message Frame = %@", NSStringFromCGRect(_messageLbl.frame));
}

+(float)cellHeightForText:(NSString *)message{
    CGSize size = [STMessageReceivedCell sizeForText:message];
    NSLog(@"Message: %@", message);
    NSLog(@"Message Size = %@", NSStringFromCGSize(size));
    return size.height + 29.f;
}

@end

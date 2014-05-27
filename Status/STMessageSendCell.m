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
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

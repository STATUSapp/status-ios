//
//  InviteFriendCell.m
//  Status
//
//  Created by Silviu Burlacu on 29/10/15.
//  Copyright © 2015 Andrus Cosmin. All rights reserved.
//

#import "STInviteFriendCell.h"
#import "STAddressBookContact.h"

@interface STInviteFriendCell ()

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblDetails;
@property (weak, nonatomic) IBOutlet UIImageView *selectedIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrTop;
@property (weak, nonatomic) IBOutlet UIImageView *divider;

@end

@implementation STInviteFriendCell


- (void)setupWithContact:(STAddressBookContact *)contact showEmail:(BOOL)showEmail isLastInSection:(BOOL)lastInSection{
    _lblDetails.hidden = !showEmail;
    _lblDetails.text = contact.emails.firstObject;
    _lblName.text = contact.fullName;
    _constrTop.constant = showEmail ? 18.0f : 25.0f;

    if (contact.selected.boolValue) {
        self.selectedIndicator.image = [UIImage imageNamed:@"checked"];
    }else {
        self.selectedIndicator.image = [UIImage imageNamed:@"unchecked"];
    }
    self.accessoryView.tintColor = [UIColor whiteColor];
    
    _divider.hidden = lastInSection;
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)prepareForReuse{
    [super prepareForReuse];
    self.accessoryType = UITableViewCellAccessoryNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

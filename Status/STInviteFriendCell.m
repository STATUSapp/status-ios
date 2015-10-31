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

@end

@implementation STInviteFriendCell


- (void)setupWithContact:(STAddressBookContact *)contact showEmail:(BOOL)showEmail{
    _lblDetails.hidden = !showEmail;
    _lblDetails.text = contact.emails.firstObject;
    _lblName.text = contact.fullName;

    if (contact.selected.boolValue) {
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    }else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    self.accessoryView.tintColor = [UIColor whiteColor];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)prepareForReuse{
    self.accessoryType = UITableViewCellAccessoryNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

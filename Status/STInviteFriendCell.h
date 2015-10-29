//
//  InviteFriendCell.h
//  Status
//
//  Created by Silviu Burlacu on 29/10/15.
//  Copyright © 2015 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STAddressBookContact;

@interface STInviteFriendCell : UITableViewCell

- (void)setupWithContact:(STAddressBookContact *)contact showEmail:(BOOL)showEmail;

@end

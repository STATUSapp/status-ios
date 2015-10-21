//
//  STSMSEmailInviterViewController.h
//  Status
//
//  Created by Silviu Burlacu on 06/10/15.
//  Copyright © 2015 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, STInviteType) {
    STInviteTypeEmail = 0,
    STInviteTypeSMS,
    STInviteTypeFacebook
};

@protocol STInvitationsDelegate <NSObject>

-(void)userDidEndSelectingInvitations;

@end

@interface STSMSEmailInviterViewController : UITableViewController

@property (nonatomic, weak) id <STInvitationsDelegate> delegate;
@property (nonatomic) STInviteType inviteType;

+ (STSMSEmailInviterViewController *)newControllerWithInviteType:(STInviteType)inviteType delegate:(id<STInvitationsDelegate>)delegate;

@end

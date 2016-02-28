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

@class STSMSEmailInviterViewController;

@protocol STInvitationsDelegate <NSObject>

-(void)userDidInviteSelectionsFromController:(STSMSEmailInviterViewController *)controller;

@optional

- (void)inviterStartedScrolling;
- (void)inviterEndedScrolling;

@end

@interface STSMSEmailInviterViewController : UIViewController

@property (nonatomic, weak) id <STInvitationsDelegate> delegate;
@property (nonatomic) STInviteType inviteType;

+ (STSMSEmailInviterViewController *)newControllerWithInviteType:(STInviteType)inviteType delegate:(id<STInvitationsDelegate>)delegate;

- (void)parentStartedScrolling;
- (void)parentEndedScrolling;

@end

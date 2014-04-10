//
//  ViewController.h
//  Status
//
//  Created by Andrus Cosmin on 16/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STConstants.h"

@interface STFlowTemplateViewController : UIViewController

@property (nonatomic, assign) STFlowType flowType;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *postID;
-(void) handleNotification:(NSDictionary *) notif;
- (void)updateNotificationsNumber;
@end

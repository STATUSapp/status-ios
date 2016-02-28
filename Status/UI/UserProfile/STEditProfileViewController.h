//
//  STEditProfileViewController.h
//  Status
//
//  Created by Silviu Burlacu on 03/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STUserProfile.h"

@interface STEditProfileViewController : UIViewController

@property (nonatomic, strong) STUserProfile * userProfile;

+ (STEditProfileViewController *)newControllerWithUserId:(NSString *)userId;


@end

//
//  STEditProfileViewController.h
//  Status
//
//  Created by Silviu Burlacu on 03/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STEditProfileViewController : UIViewController

@property (nonatomic, strong) NSDictionary * userProfileDict;

+ (STEditProfileViewController *)newControllerWithUserId:(NSString *)userId;


@end

//
//  STUserProfileViewController.h
//  Status
//
//  Created by Silviu Burlacu on 03/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STUserProfileViewController : UIViewController

@property (nonatomic, assign) BOOL isMyProfile;

+(STUserProfileViewController *)newControllerWithUserId:(NSString *)userId;

+(id)getObjectFromUserProfileDict:(NSDictionary *)dict forKey:(NSString *)key;

@end

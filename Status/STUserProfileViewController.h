//
//  STUserProfileViewController.h
//  Status
//
//  Created by Silviu Burlacu on 03/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STUserProfileControllerDelegate <NSObject>
- (void)advanceToNextProfile;
@end

@interface STUserProfileViewController : UIViewController

@property (nonatomic, assign) BOOL isMyProfile;
@property (nonatomic, assign) BOOL isLaunchedFromNearbyController;
@property (nonatomic, weak) id<STUserProfileControllerDelegate> delegate;

+(STUserProfileViewController *)newControllerWithUserId:(NSString *)userId;
+(STUserProfileViewController *)newControllerWithUserInfoDict:(NSDictionary *)userInfo;

+(id)getObjectFromUserProfileDict:(NSDictionary *)dict forKey:(NSString *)key;

- (NSDictionary *)userProfileDict;

@end
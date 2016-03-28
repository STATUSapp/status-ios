//
//  STUserProfileViewController.h
//  Status
//
//  Created by Silviu Burlacu on 03/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STUserProfile.h"

@protocol STUserProfileControllerDelegate <NSObject>
- (void)advanceToNextProfile;
@end

@interface STUserProfileViewController : UIViewController

@property (nonatomic, assign) BOOL isMyProfile;
@property (nonatomic, assign) BOOL isLaunchedFromNearbyController;
@property (nonatomic, assign) BOOL shouldOpenCameraRoll;
@property (nonatomic, assign) BOOL shouldHideBackButton;

@property (nonatomic, weak) id<STUserProfileControllerDelegate> delegate;

+(STUserProfileViewController *)newControllerWithUserId:(NSString *)userId;
+(STUserProfileViewController *)newControllerWithUserUserDataModel:(STUserProfile *)userProfile;

- (STUserProfile *)userProfile;

@end
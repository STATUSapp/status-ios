//
//  STTabBarViewController.h
//  Status
//
//  Created by Silviu Burlacu on 28/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STTabBarViewController : UITabBarController

+ (instancetype)newController;

- (void)setActivityIcon;

- (void)dismissChoosePhotoVC;

- (void)setTabBarHidden:(BOOL)tabBarHidden;
- (void)setTabBarFrame:(CGRect)rect;

@end

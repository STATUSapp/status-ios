//
//  AppDelegate.h
//  Status
//
//  Created by Andrus Cosmin on 16/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) NSInteger badgeNumber;
@property (nonatomic, strong) NSDictionary * settingsDict;

-(void)checkForNotificationNumber;

@end

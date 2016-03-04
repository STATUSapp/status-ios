//
//  CoreManager.h
//  Status
//
//  Created by Silviu Burlacu on 28/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STPostsPool;
@class STLocationManager;
@class STNetworkQueueManager;
@class STNavigationService;
@class STFacebookLoginController;
@class STImageCacheController;
@class STFacebookHelper;
@class STIAPHelper;
@class STContactsManager;

@interface CoreManager : NSObject

+ (BOOL)shouldLogin;
+ (BOOL)loggedIn;

+ (STPostsPool *)postsPool;
+ (STLocationManager *)locationService;
+ (STNetworkQueueManager *)networkService;
+ (STNavigationService *)navigationService;
+ (STFacebookLoginController *)loginService;
+ (STImageCacheController *)imageCacheService;
+ (STFacebookHelper *)facebookService;
+ (STIAPHelper *)IAPService;
+ (STContactsManager *)contactsService;

@end

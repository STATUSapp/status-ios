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
@class STImagePickerService;
@class STUsersPool;
@class STLocalNotificationService;
@class STNotificationsManager;
@class STUserProfilePool;
@class STProcessorsService;
@class BadgeService;
@class STDeepLinkService;
@class STSnackBarService;
@class STSnackBarWithActionService;
@class STCoreDataManager;
@class STSyncService;
@class STImageSuggestionsService;
@class STLoggerService;

@interface CoreManager : NSObject

+ (BOOL)shouldLogin;
+ (BOOL)loggedIn;
+ (BOOL)isGuestUser;

+ (STPostsPool *)postsPool;
+ (STLocationManager *)locationService;
+ (STNetworkQueueManager *)networkService;
+ (STNavigationService *)navigationService;
+ (STFacebookLoginController *)loginService;
+ (STImageCacheController *)imageCacheService;
+ (STFacebookHelper *)facebookService;
+ (STIAPHelper *)IAPService;
+ (STContactsManager *)contactsService;
+ (STImagePickerService *)imagePickerService;
+ (STUsersPool *)usersPool;
+ (STUserProfilePool *)profilePool;
+ (STLocalNotificationService *)localNotificationService;
+ (STNotificationsManager *)notificationsService;
+ (STProcessorsService *)processorService;
+ (BadgeService *)badgeService;
+ (STDeepLinkService *)deepLinkService;
+ (STSnackBarService *)snackBarService;
+ (STSnackBarWithActionService *)snackWithActionService;
+ (STCoreDataManager *)coreDataService;
+ (STSyncService *)syncService;
+ (STImageSuggestionsService *)imageSuggestionsService;
+ (STLoggerService *)loggerService;

@end

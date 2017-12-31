//
//  CoreManager.m
//  Status
//
//  Created by Silviu Burlacu on 28/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "CoreManager.h"
#import "STPostsPool.h"
#import "STLocationManager.h"
#import "STNetworkQueueManager.h"
#import "STNavigationService.h"
#import "STFacebookLoginController.h"
#import "STImageCacheController.h"
#import "STFacebookHelper.h"
#import "STIAPHelper.h"
#import "STContactsManager.h"
#import "STImagePickerService.h"
#import "STUsersPool.h"
#import "STUserProfilePool.h"
#import "STLocalNotificationService.h"
#import "STNotificationsManager.h"
#import "STProcessorsService.h"
#import "BadgeService.h"
#import "STDeepLinkService.h"
#import "STSnackBarService.h"
#import "STSnackBarWithActionService.h"
#import "STCoreDataManager.h"

@interface CoreManager ()
@property (nonatomic, strong) STPostsPool * postsPool;
@property (nonatomic, strong) STUsersPool *usersPool;
@property (nonatomic, strong) STUserProfilePool *profilePool;
@property (nonatomic, strong) STLocationManager *locationService;
@property (nonatomic, strong) STNetworkQueueManager *networkService;
@property (nonatomic, strong) STNavigationService *navigationService;
@property (nonatomic, strong) STFacebookLoginController *loginService;
@property (nonatomic, strong) STImageCacheController *imageCacheService;
@property (nonatomic, strong) STFacebookHelper *facebookService;
@property (nonatomic, strong) STIAPHelper *IAPService;
@property (nonatomic, strong) STContactsManager *contactsService;
@property (nonatomic, strong) STImagePickerService * imagePickerService;
@property (nonatomic, strong) STLocalNotificationService *localNotifCenter;
@property (nonatomic, strong) STNotificationsManager *notificationsService;
@property (nonatomic, strong) STProcessorsService *processorsService;
@property (nonatomic, strong) BadgeService *badgeService;
@property (nonatomic, strong) STDeepLinkService *deepLinkService;
@property (nonatomic, strong) STSnackBarService *snackBarService;
@property (nonatomic, strong) STSnackBarWithActionService *snackWithActionService;
@property (nonatomic, strong) STCoreDataManager *coreDataService;

@end

@implementation CoreManager


+ (instancetype)sharedInstance {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _postsPool = [STPostsPool new];
//        _locationService = [STLocationManager new];
        _networkService = [STNetworkQueueManager new];
        _navigationService = [STNavigationService new];
        _loginService = [STFacebookLoginController new];
        _imageCacheService = [STImageCacheController new];
        _facebookService = [STFacebookHelper new];
        _IAPService = [STIAPHelper new];
        _contactsService = [STContactsManager new];
        _imagePickerService = [STImagePickerService new];
        _usersPool = [STUsersPool new];
        _profilePool = [STUserProfilePool new];
        _localNotifCenter = [STLocalNotificationService new];
        _notificationsService = [STNotificationsManager new];
        _processorsService = [STProcessorsService new];
        _badgeService = [BadgeService new];
        _deepLinkService = [STDeepLinkService new];
        _snackBarService = [STSnackBarService new];
        _snackWithActionService = [STSnackBarWithActionService new];
        _coreDataService = [STCoreDataManager new];
    }
    return self;
}

#pragma mark - Public interface

+ (BOOL)shouldLogin {
    return [[CoreManager sharedInstance] shouldLogin];
}

+ (BOOL)loggedIn{
    return [[CoreManager sharedInstance] loggedIn] && ![[CoreManager sharedInstance] isGuestUser];
}

+ (STPostsPool *)postsPool {
    return [[CoreManager sharedInstance] postsPool];
}

+ (STLocationManager *)locationService{
    return nil;
//    return [[CoreManager sharedInstance] locationService];
}

+ (STNetworkQueueManager *)networkService{
    return [[CoreManager sharedInstance] networkService];
}

+ (STNavigationService *)navigationService{
    return [[CoreManager sharedInstance] navigationService];
}

+ (STFacebookLoginController *)loginService{
    return [[CoreManager sharedInstance] loginService];
}

+ (STImageCacheController *)imageCacheService{
    return [[CoreManager sharedInstance] imageCacheService];
}

+ (STFacebookHelper *)facebookService{
    return [[CoreManager sharedInstance] facebookService];
}

+ (STIAPHelper *)IAPService{
    return [[CoreManager sharedInstance] IAPService];
}

+ (STContactsManager *)contactsService{
    return [[CoreManager sharedInstance] contactsService];
}

+ (STImagePickerService *)imagePickerService {
    return [[CoreManager sharedInstance] imagePickerService];
}

+ (STUsersPool *)usersPool{
    return [[CoreManager sharedInstance] usersPool];
}

+ (STUserProfilePool *)profilePool{
    return [[CoreManager sharedInstance] profilePool];
}

+ (STLocalNotificationService *)localNotificationService{
    return [[CoreManager sharedInstance] localNotifCenter];
}

+ (STNotificationsManager *)notificationsService{
    return [[CoreManager sharedInstance] notificationsService];
}

+ (STProcessorsService *)processorService{
    return [[CoreManager sharedInstance] processorsService];
}

+(BadgeService *)badgeService{
    return [[CoreManager sharedInstance] badgeService];
}

+ (STDeepLinkService *)deepLinkService{
    return [[CoreManager sharedInstance] deepLinkService];
}

+(STSnackBarService *)snackBarService{
    return [[CoreManager sharedInstance] snackBarService];
}

+(STSnackBarWithActionService *)snackWithActionService{
    return [[CoreManager sharedInstance] snackWithActionService];
}

+(STCoreDataManager *)coreDataService{
    return [[CoreManager sharedInstance] coreDataService];
}
#pragma mark - Private implementation

- (BOOL)shouldLogin {
    return ![self loggedIn];
}

- (BOOL)loggedIn{
    NSString *accessToken = [_networkService getAccessToken];
    return (accessToken!=nil && accessToken.length > 0);
}

- (BOOL)isGuestUser{
    return [_loginService isGuestUser];
}

@end

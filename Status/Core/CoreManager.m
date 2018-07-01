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
#import "STLoginService.h"
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
#import "STSyncService.h"
#import "STImageSuggestionsService.h"
#import "STLoggerService.h"
#import "STInstagramLoginService.h"
#import "STImageResizeService.h"
#import "STResetBaseUrlService.h"

#import "SDWebImageManager.h"

@interface CoreManager ()
@property (nonatomic, strong) STPostsPool * postsPool;
@property (nonatomic, strong) STUsersPool *usersPool;
@property (nonatomic, strong) STUserProfilePool *profilePool;
@property (nonatomic, strong) STLocationManager *locationService;
@property (nonatomic, strong) STNetworkQueueManager *networkService;
@property (nonatomic, strong) STNavigationService *navigationService;
@property (nonatomic, strong) STLoginService *loginService;
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
@property (nonatomic, strong) STSyncService *syncService;
@property (nonatomic, strong) STImageSuggestionsService *imageSuggestionsService;
@property (nonatomic, strong) STLoggerService *loggerService;
@property (nonatomic, strong) STInstagramLoginService *instagramLoginService;
@property (nonatomic, strong) STImageResizeService *imageResizeService;
@property (nonatomic, strong) STResetBaseUrlService *resetBaseUrlService;

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
        _loginService = [STLoginService new];
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
        _syncService = [STSyncService new];
        _imageSuggestionsService = [STImageSuggestionsService new];
        _loggerService = [STLoggerService new];
        _instagramLoginService = [STInstagramLoginService new];
        _imageResizeService = [STImageResizeService new];
        _resetBaseUrlService = [STResetBaseUrlService new];
        
        [SDWebImageManager sharedManager].imageCache.config.shouldDecompressImages = NO;
        [SDWebImageDownloader sharedDownloader].shouldDecompressImages = NO;
        [SDWebImageManager sharedManager].imageDownloader.maxConcurrentDownloads = 6;
    }
    return self;
}

#pragma mark - Public interface

+ (BOOL)shouldLogin {
    return [[CoreManager sharedInstance] shouldLogin];
}

+ (BOOL)loggedIn{
    return [[CoreManager sharedInstance] loggedIn];
}

+ (BOOL)isGuestUser{
    return [[CoreManager sharedInstance] isGuestUser];
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

+ (STLoginService *)loginService{
    return [[CoreManager sharedInstance] loginService];
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
+(STSyncService *)syncService{
    return [[CoreManager sharedInstance] syncService];
}

+(STImageSuggestionsService *)imageSuggestionsService{
    return [[CoreManager sharedInstance] imageSuggestionsService];
}

+(STLoggerService *)loggerService{
    return [[CoreManager sharedInstance] loggerService];
}

+ (STInstagramLoginService *)instagramLoginService{
    return [[CoreManager sharedInstance] instagramLoginService];
}

+ (STImageResizeService *)imageResizeService{
    return [[CoreManager sharedInstance] imageResizeService];
}

+ (STResetBaseUrlService *)resetBaseUrlService{
    return [[CoreManager sharedInstance] resetBaseUrlService];
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

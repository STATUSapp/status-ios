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

@interface CoreManager ()
@property (nonatomic, strong) STPostsPool * postsPool;
@property (nonatomic, strong) STLocationManager *locationService;
@property (nonatomic, strong) STNetworkQueueManager *networkService;
@property (nonatomic, strong) STNavigationService *navigationService;
@property (nonatomic, strong) STFacebookLoginController *loginService;
@property (nonatomic, strong) STImageCacheController *imageCacheService;
@property (nonatomic, strong) STFacebookHelper *facebookService;
@property (nonatomic, strong) STIAPHelper *IAPService;
@property (nonatomic, strong) STContactsManager *contactsService;
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
        _postsPool = [[STPostsPool alloc] init];
        _locationService = [[STLocationManager alloc] init];
        _networkService = [[STNetworkQueueManager alloc] init];
        _navigationService = [STNavigationService new];
        _loginService = [STFacebookLoginController new];
        _imageCacheService = [STImageCacheController new];
        _facebookService = [STFacebookHelper new];
        _IAPService = [STIAPHelper new];
        _contactsService = [STContactsManager new];
        
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

+ (STPostsPool *)postsPool {
    return [[CoreManager sharedInstance] postsPool];
}

+ (STLocationManager *)locationService{
    return [[CoreManager sharedInstance] locationService];
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

#pragma mark - Private implementation

- (BOOL)shouldLogin {
    return ![self loggedIn];
}

- (BOOL)loggedIn{
    NSString *accessToken = [_networkService getAccessToken];
    return (accessToken!=nil && accessToken.length > 0);
}

@end

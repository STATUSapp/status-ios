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

@interface CoreManager ()
@property (nonatomic, strong) STPostsPool * postsPool;
@property (nonatomic, strong) STLocationManager *locationService;
@property (nonatomic, strong) STNetworkQueueManager *networkService;
@property (nonatomic, strong) STNavigationService *navigationService;
@property (nonatomic, strong) STFacebookLoginController *loginService;

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

#pragma mark - Private implementation

- (BOOL)shouldLogin {
    return ![self loggedIn];
}

- (BOOL)loggedIn{
    NSString *accessToken = [_networkService getAccessToken];
    return (accessToken!=nil && accessToken.length > 0);
}

@end

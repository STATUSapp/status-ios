//
//  STNetworkQueueManager.m
//  Status
//
//  Created by Cosmin Andrus on 19/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STNetworkQueueManager.h"
#import "STBaseRequest.h"
#import <netinet/in.h>
#import <arpa/inet.h>
#import "STChatController.h"
#import "STRequests.h"
#import "KeychainItemWrapper.h"
#import "STNetworkManager.h"
#import "KeychainItemWrapper.h"

#ifdef DEBUG
    #define TEST_HIT_REQUESTS 1
#else
    #define TEST_HIT_REQUESTS 0
#endif

NSInteger const kMaxConcurentDownloads = 5;

@interface STNetworkQueueManager() {
    AFNetworkReachabilityManager* _reachabilityManager;
}
@property (nonatomic, strong, readwrite) NSString *baseUrl;

@property (nonatomic, strong) NSMutableArray* requestQueue;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) STNetworkManager *networkAPI;
@property (nonatomic, strong) KeychainItemWrapper *keychain;
#if TEST_HIT_REQUESTS
@property (nonatomic, strong) NSMutableDictionary *hitAPIs;
@property (nonatomic, strong) NSMutableDictionary *errorAPIs;
#endif
@end

@implementation STNetworkQueueManager

-(instancetype)init{
    self = [super init];
    if (self) {
        self.requestQueue = [NSMutableArray new];
        [self loadNetworkAPI];
        _keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"STUserAuthToken" accessGroup:nil];
        _accessToken = [_keychain objectForKey:(__bridge id)(kSecValueData)];
        NSLog(@"Loaded Access Token: %@",_accessToken);

#if TEST_HIT_REQUESTS
        _hitAPIs =[@{} mutableCopy];
        _errorAPIs =[@{} mutableCopy];
#endif
    }
    return self;
}

-(void)loadNetworkAPI{
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"BaseUrl"];
    NSString *baseUrl = [ud valueForKey:@"BASE_URL"];
    
    if (!baseUrl) {
        baseUrl = kBaseURL;
    }
    _baseUrl = baseUrl;
    _networkAPI = [[STNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];

}

-(void)reset{
    [_networkAPI clearQueue];
}

+(STNetworkManager *)networkAPI{
    return [[CoreManager networkService] networkAPI];
}

#pragma mark - Access Token

- (void)setAccessToken:(NSString *)accessToken{
    _accessToken = accessToken;
    [_keychain setObject:accessToken forKey:(__bridge id)(kSecValueData)];

    
}

- (NSString *)getAccessToken{
    return _accessToken;
}

#pragma mark - utils methods
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark - queue operation
- (void)startDownload{
    NSInteger inProgressRequestsCount = [self numberOfInProgressRequests];
    NSArray *notStartedArray = [self notStartedRequests];
    while (inProgressRequestsCount <= kMaxConcurentDownloads && notStartedArray.count > 0) {
        [notStartedArray[0] retry];
        inProgressRequestsCount = [self numberOfInProgressRequests];
        notStartedArray = [self notStartedRequests];
    }
}

- (NSInteger)numberOfInProgressRequests{
    NSArray *inProgressArray = [self.requestQueue filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"inProgress == 1"]];
    return inProgressArray.count;
}

- (NSArray *)notStartedRequests{
    NSArray *notStartedArray = [self.requestQueue filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"inProgress == 0"]];
    return notStartedArray;
}

#pragma mark - Queue handlers

- (void)addToQueue:(STBaseRequest*)request
             onTop:(BOOL)onTop{
    
    if (![self isConnectionWorking]){
        request.failureBlock([NSError errorWithDomain:@"Error" code:kHTTPErrorNoConnection userInfo:nil]);
    }else{
        if (onTop) {
            [_requestQueue insertObject:request atIndex:0];
        }else{
            [_requestQueue addObject:request];
        }
        [self startDownload];
    }
}

- (void)addToQueue:(STBaseRequest*)request{
    [self addToQueue:request onTop:NO];
}

- (void)addToQueueTop:(STBaseRequest*)request{
    [self addToQueue:request onTop:YES];
}

- (void)removeFromQueue:(STBaseRequest*)request{
    [_requestQueue removeObject:request];
}

- (void)clearQueue{
    [_requestQueue removeAllObjects];
    [self loadNetworkAPI];
}

- (BOOL)canSendLoginOrRegisterRequest{
    BOOL result = YES;
    for (STBaseRequest *request in _requestQueue) {
        if ([request isKindOfClass:[STLoginRequest class]] ||
            [request isKindOfClass:[STRegisterRequest class]]) {
            result = NO;
            break;
        }
    }
    return result;
}


- (void)addOrHideActivity{
    
    if (_requestQueue.count > 0 && ![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]){
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }else{
        if (_requestQueue.count == 0) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    }
}

#pragma mark - Network handlers

- (void)requestDidSucceed:(STBaseRequest*)request{
#if TEST_HIT_REQUESTS
    NSString *key = [request urlString];
    if (![_hitAPIs valueForKey:key]) {
        [_hitAPIs setValue:@"OK" forKey:key];
    }
#endif
    [self removeFromQueue:request];
    [self startDownload];
    [self addOrHideActivity];
}

- (void)request:(STBaseRequest*)request didFailWithError:(NSError*)error{
#if TEST_HIT_REQUESTS
    NSString *key = [request urlString];
    if (![_errorAPIs valueForKey:key]) {
        [_errorAPIs setValue:[NSString stringWithFormat:@"Error: %@", error] forKey:key];
    }
#endif
    [self removeFromQueue:request];
    if (request.shouldAddToQueue)
        [self addToQueue:request onTop:YES];
    
    [self addOrHideActivity];
    //First check reachability
    if ([self isConnectionWorking]) {
        [self startDownload];
    } else{
        [self removeFromQueue:request];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

- (BOOL)isConnectionWorking {
    return [STChatController sharedInstance].connectionStatus != STConnectionStatusOff;
}

-(void)deleteAccessToken {
    [_keychain resetKeychainItem];
    [_networkAPI clearQueue];
    _accessToken = nil;
}

- (void)setPhotoDownloadBaseUrl:(NSString *)photoDownloadBaseUrl{
    _photoDownloadBaseUrl = photoDownloadBaseUrl;
}

-(NSString *)debugDescription{
#if TEST_HIT_REQUESTS
    NSLog(@"TEST REQUESTS\nSUCCESS REQUESTS (%@) \n%@", @([_hitAPIs.allKeys count]), [_hitAPIs allKeys]);
    NSLog(@"TEST REQUESTS\nERROR REQUESTS (%@) \n%@", @([_errorAPIs.allKeys count]), [_errorAPIs allKeys]);

#endif
    return @"No debug desctiption provided";
}
@end

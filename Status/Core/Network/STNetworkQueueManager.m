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

        [self loadTokenFromKeyChain];
        
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
    if (_requestQueue.count > 0){
        [_requestQueue[0] retry];
    }
    
}

#pragma mark - Queue handlers

- (void)addToQueue:(STBaseRequest*)request{
    
    [_requestQueue addObject:request];
    if (_requestQueue.count == 1 && [self isConnectionWorking]){
        [_requestQueue[0] retry];
    } else if (![self isConnectionWorking]){
        [_requestQueue removeObject:request];
        request.failureBlock([NSError errorWithDomain:@"Error" code:kHTTPErrorNoConnection userInfo:nil]);
    }
    
}

- (void)addToQueueTop:(STBaseRequest*)request{
    
    [_requestQueue insertObject:request atIndex:0];
    if (_requestQueue.count == 1 && [self isConnectionWorking]){
        [_requestQueue[0] retry];
    } else if (![self isConnectionWorking]){
        
        [_requestQueue removeObject:request];
        request.completionBlock(nil,[NSError errorWithDomain:@"Error" code:kHTTPErrorNoConnection userInfo:nil]);
    }
    
}

- (void)removeFromQueue:(STBaseRequest*)request{
    [_requestQueue removeObject:request];
}

- (void)clearQueue{
    [_requestQueue removeAllObjects];
    [self loadNetworkAPI];
}

- (BOOL)saveQueueToDisk{
    
    NSMutableArray *subQueue = [[_requestQueue filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isPost = YES"]] mutableCopy];
    
    NSString* fileName = [NSString stringWithFormat:@"%@/pendingRequests.plist", [self applicationDocumentsDirectory]];
    return [NSKeyedArchiver archiveRootObject:subQueue toFile:fileName];
}

- (void)loadQueueFromDisk{
    NSString* fileName = [NSString stringWithFormat:@"%@/pendingRequests.plist", [self applicationDocumentsDirectory]];
    NSMutableArray* savedReqQueue = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
    if (savedReqQueue) {
        _requestQueue = savedReqQueue;
    }
    else {
        _requestQueue = [NSMutableArray new];
    }
    
    [self deleteQueueFileFromDisk];
    [self startDownload];
}

- (void)deleteQueueFileFromDisk
{
    NSString* fileName = [NSString stringWithFormat:@"%@/pendingRequests.plist", [self applicationDocumentsDirectory]];
    [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
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
    [_requestQueue removeObject:request];
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
    [_requestQueue removeObject:request];
    
    if (request.shouldAddToQueue)
        [_requestQueue addObject:request];
    
    [self addOrHideActivity];
    //First check reachability
    if ([self isConnectionWorking]) {
        [self startDownload];
    } else
    {
        [_requestQueue removeObject:request];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

- (BOOL)isConnectionWorking {
    return [STChatController sharedInstance].connectionStatus != STConnectionStatusOff;
}

-(void)loadTokenFromKeyChain {
    _accessToken = [_keychain objectForKey:(__bridge id)(kSecValueData)];
    NSLog(@"Loaded Access Token: %@",_accessToken);
}

-(void)deleteAccessToken {
    [_keychain resetKeychainItem];
    [_networkAPI clearQueue];
    _accessToken = nil;
}


-(NSString *)debugDescription{
#if TEST_HIT_REQUESTS
    NSLog(@"TEST REQUESTS\nSUCCESS REQUESTS (%@) \n%@", @([_hitAPIs.allKeys count]), [_hitAPIs allKeys]);
    NSLog(@"TEST REQUESTS\nERROR REQUESTS (%@) \n%@", @([_errorAPIs.allKeys count]), [_errorAPIs allKeys]);

#endif
    return @"No debug desctiption provided";
}
@end

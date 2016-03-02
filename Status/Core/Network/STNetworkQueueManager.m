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

@interface STNetworkQueueManager()<UIAlertViewDelegate> {
    AFNetworkReachabilityManager* _reachabilityManager;
}

@property (nonatomic, strong) NSMutableArray* requestQueue;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) STNetworkManager *networkAPI;

@end

@implementation STNetworkQueueManager

-(instancetype)init{
    self = [super init];
    if (self) {
        self.requestQueue = [NSMutableArray new];
        _networkAPI = [[STNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL]];
        [self loadTokenFromKeyChain];
    }
    return self;
}

+(STNetworkManager *)networkAPI{
    return [[CoreManager networkService] networkAPI];
}

#pragma mark - Access Token

- (void)setAccessToken:(NSString *)accessToken{
    _accessToken = accessToken;
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
    [_requestQueue removeObject:request];
    [self startDownload];
    [self addOrHideActivity];
}

- (void)request:(STBaseRequest*)request didFailWithError:(NSError*)error{
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
    KeychainItemWrapper *keychainWrapperAccessToken = [[KeychainItemWrapper alloc] initWithIdentifier:@"STUserAuthToken" accessGroup:nil];
    _accessToken = [keychainWrapperAccessToken objectForKey:(__bridge id)(kSecValueData)];
    NSLog(@"Loaded Access Token: %@",_accessToken);
}

-(void)deleteAccessToken {
    KeychainItemWrapper *keychainWrapperAccessToken = [[KeychainItemWrapper alloc] initWithIdentifier:@"STUserAuthToken" accessGroup:nil];
    [keychainWrapperAccessToken resetKeychainItem];
    [_networkAPI clearQueue];
    _accessToken = nil;
}

@end

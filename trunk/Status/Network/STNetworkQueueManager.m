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

@interface STNetworkQueueManager()<UIAlertViewDelegate> {
    AFNetworkReachabilityManager* _reachabilityManager;
}
@end

@implementation STNetworkQueueManager

+ (STNetworkQueueManager *)sharedManager {
    static STNetworkQueueManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[STNetworkQueueManager alloc] init];
        _sharedManager.requestQueue = [NSMutableArray new];
        _sharedManager.isPerformLoginOrRegistration=FALSE;

    });
    
    return _sharedManager;
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




- (void)addOrHideActivity{
    
    if ([STNetworkQueueManager sharedManager].requestQueue.count > 0 && ![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]){
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }else{
        if ([STNetworkQueueManager sharedManager].requestQueue.count == 0) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    }
}

#pragma mark - Network handlers

- (void)requestDidSucceed:(STBaseRequest*)request{
    [[STNetworkQueueManager sharedManager].requestQueue removeObject:request];
    [[STNetworkQueueManager sharedManager] startDownload];
    [self addOrHideActivity];
}

- (void)request:(STBaseRequest*)request didFailWithError:(NSError*)error{
    [[STNetworkQueueManager sharedManager].requestQueue removeObject:request];
    
    if (request.shouldAddToQueue)
        [[STNetworkQueueManager sharedManager].requestQueue addObject:request];
    
    [self addOrHideActivity];
    //First check reachability
    if ([self isConnectionWorking]) {
        [[STNetworkQueueManager sharedManager] startDownload];
    } else
    {
        [[STNetworkQueueManager sharedManager].requestQueue removeObject:request];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

- (BOOL)isConnectionWorking {
    return [STChatController sharedInstance].connectionStatus == STConnectionStatusOn;
}
@end

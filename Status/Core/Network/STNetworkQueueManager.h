//
//  STNetworkQueueManager.h
//  Status
//
//  Created by Cosmin Andrus on 19/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STBaseRequest;
@class STNetworkManager;

@interface STNetworkQueueManager : NSObject

+(STNetworkManager *)networkAPI;

- (NSString *)getAccessToken;
- (void)setAccessToken:(NSString *)accessToken;

- (void)startDownload;

//Queue handlers
- (void)addToQueue:(STBaseRequest*)request;
- (void)addToQueueTop:(STBaseRequest*)request;
- (void)removeFromQueue:(STBaseRequest*)request;
- (void)clearQueue;
- (void)loadQueueFromDisk;
- (BOOL)saveQueueToDisk;
- (void)deleteQueueFileFromDisk;

- (BOOL)canSendLoginOrRegisterRequest;

//Network handlers
- (void)requestDidSucceed:(STBaseRequest*)request;
- (void)request:(STBaseRequest*)request didFailWithError:(NSError*)error;

- (BOOL)isConnectionWorking;

- (void)deleteAccessToken;
- (void)loadTokenFromKeyChain;

@end

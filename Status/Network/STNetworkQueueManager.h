//
//  STNetworkQueueManager.h
//  Status
//
//  Created by Cosmin Andrus on 19/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STBaseRequest;

@interface STNetworkQueueManager : NSObject

@property(nonatomic, strong) NSMutableArray* requestQueue;
@property (nonatomic, strong) NSString *accessToken;
@property (atomic, assign) BOOL isPerformLoginOrRegistration;

+ (STNetworkQueueManager *)sharedManager;

- (void)startDownload;

//Queue handlers
- (void)addToQueue:(STBaseRequest*)request;
- (void)addToQueueTop:(STBaseRequest*)request;
- (void)removeFromQueue:(STBaseRequest*)request;
- (void)loadQueueFromDisk;
- (BOOL)saveQueueToDisk;
- (void)deleteQueueFileFromDisk;


//Network handlers
- (void)requestDidSucceed:(STBaseRequest*)request;
- (void)request:(STBaseRequest*)request didFailWithError:(NSError*)error;

- (BOOL)isConnectionWorking;

@end

//
//  STBaseRequest.h
//  Status
//
//  Created by Cosmin Andrus on 19/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "STNetworkManager.h"
#import "STNetworkQueueManager.h"

typedef void (^STRequestCompletionBlock)(id response, NSError *error);
typedef void (^STRequestExecutionBlock)(void);
typedef void (^STRequestFailureBlock)(NSError *error);
typedef void (^STRequestStandardSuccessBlock)(NSURLSessionDataTask *task, id responseObject);
typedef void (^STRequestStandardErrorBlock)(NSURLSessionDataTask *task, NSError *error);


//how much would you like for your server requests to fail
static int const kBCRequestRetryCount = 0;

@interface STBaseRequest : NSObject<NSCoding>

@property (nonatomic,assign) int retryCount;
@property (nonatomic,strong) NSDictionary *returnAttributes;
@property (nonatomic, strong) NSDictionary *params;

@property (nonatomic,copy) STRequestExecutionBlock executionBlock;
@property (nonatomic,copy) STRequestCompletionBlock completionBlock;
@property (nonatomic,copy) STRequestFailureBlock failureBlock;
@property (nonatomic, copy) STRequestStandardSuccessBlock standardSuccessBlock;
@property (nonatomic, copy) STRequestStandardErrorBlock standardErrorBlock;
@property (nonatomic, copy) NSNumber *timeStamp;
@property (nonatomic, assign, readonly) BOOL inProgress;
@property (nonatomic,assign) BOOL shouldAddToQueue;

//Methods
- (void)retry;
- (void)requestFailedWithError:(NSError*)error;

- (NSError*)translateToHTTPError:(NSURLSessionDataTask *)task error:(NSError *)error;

-(void)failRequestWithError:(NSError*)err;
//vitual methods
-(NSString *)urlString;

//helpers
-(NSNumber *)getTimeZoneOffsetFromGMT;
-(NSString *)getAppVersion;
- (NSMutableDictionary *)getDictParamsWithToken;

@end

//
//  STNetworkManager.m
//  Status
//
//  Created by Cosmin Andrus on 19/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STNetworkManager.h"
#import "STNetworkQueueManager.h"

@implementation STNetworkManager

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    self.operationQueue.maxConcurrentOperationCount = 1;
    AFJSONResponseSerializer *jsonReponseSerializer;
    jsonReponseSerializer = [STNetworkManager customResponseSerializer];
    self.responseSerializer = jsonReponseSerializer;
    
    self.requestSerializer = [AFHTTPRequestSerializer serializer];

    //use default SSL implementation
    self.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];

    return self;
}

+ (AFJSONResponseSerializer *)customResponseSerializer {
    AFJSONResponseSerializer *jsonReponseSerializer = [AFJSONResponseSerializer serializer];
    // This will make the AFJSONResponseSerializer accept any content type
    jsonReponseSerializer.acceptableContentTypes = nil;
    return jsonReponseSerializer;
}

- (void)clearQueue{
    [[self operationQueue] cancelAllOperations];
    [self invalidateSessionCancelingTasks:YES];

    __weak STNetworkManager *weakSelf = self;
    [[self session] getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        __strong STNetworkManager *strongSelf = weakSelf;
        [strongSelf cancelTasksInArray:dataTasks];
        [strongSelf cancelTasksInArray:uploadTasks];
        [strongSelf cancelTasksInArray:downloadTasks];
    }];
    [[CoreManager networkService] clearQueue];

}

- (void)cancelTasksInArray:(NSArray *)tasksArray
{
    for (NSURLSessionTask *task in tasksArray) {
        [task cancel];
    }
}

@end

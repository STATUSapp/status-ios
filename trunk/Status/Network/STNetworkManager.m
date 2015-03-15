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
static STNetworkManager *_sharedManager = nil;

+ (STNetworkManager *)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[STNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL]];
    });
    
    return _sharedManager;
}

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

    return self;
}

+ (AFJSONResponseSerializer *)customResponseSerializer {
    AFJSONResponseSerializer *jsonReponseSerializer = [AFJSONResponseSerializer serializer];
    // This will make the AFJSONResponseSerializer accept any content type
    jsonReponseSerializer.acceptableContentTypes = nil;
    return jsonReponseSerializer;
}

- (void)clearQueue{
    [[STNetworkQueueManager sharedManager].requestQueue removeAllObjects];
    [[self operationQueue] cancelAllOperations];
    [self invalidateSessionCancelingTasks:YES];
    _sharedManager = [[STNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL]];

    [[self session] getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        [self cancelTasksInArray:dataTasks];
        [self cancelTasksInArray:uploadTasks];
        [self cancelTasksInArray:downloadTasks];
    }];
}

- (void)cancelTasksInArray:(NSArray *)tasksArray
{
    for (NSURLSessionTask *task in tasksArray) {
        [task cancel];
    }
}

@end

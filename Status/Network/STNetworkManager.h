//
//  STNetworkManager.h
//  Status
//
//  Created by Cosmin Andrus on 19/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface STNetworkManager : AFHTTPSessionManager

+ (STNetworkManager *)sharedManager;
- (void)clearQueue;
+ (AFJSONResponseSerializer *)customResponseSerializer;

@end

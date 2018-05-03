//
//  STSetUserLocationRequest.m
//  Status
//
//  Created by Cosmin Andrus on 30/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STSetUserLocationRequest.h"
#import "STLocationManager.h"

@implementation STSetUserLocationRequest
+ (void)setCurrentUserLocationWithCompletion:(STRequestCompletionBlock)completion
                                     failure:(STRequestFailureBlock)failure{
    
    STSetUserLocationRequest *request = [STSetUserLocationRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STSetUserLocationRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        __strong STSetUserLocationRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
        CLLocationCoordinate2D coord = [CoreManager locationService].latestLocation.coordinate;
        params[@"lat"] = @(coord.latitude);
        params[@"lng"] = @(coord.longitude);
        strongSelf.params = params;
        [[STNetworkQueueManager networkAPI] POST:url
                                      parameters:params
                                        progress:nil
                                         success:strongSelf.standardSuccessBlock
                                         failure:strongSelf.standardErrorBlock];
    };

    return executionBlock;
}

-(NSString *)urlString{
    return kSetUserLocation;
}

@end

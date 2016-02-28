//
//  STFlowImagesRequest.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 01/08/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STFlowImagesRequest.h"
#import "STLocationManager.h"

@implementation STFlowImagesRequest
+ (void)getFlowImagesWithCompletion:(STRequestCompletionBlock)completion
                            failure:(STRequestFailureBlock)failure{
    
    STFlowImagesRequest *request = [STFlowImagesRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    [[STNetworkQueueManager sharedManager] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STFlowImagesRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        NSString *url = [weakSelf urlString];
        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];
        if ([STLocationManager locationUpdateEnabled])
        {CLLocationCoordinate2D coord = [STLocationManager sharedInstance].latestLocation.coordinate;
            params[@"lat"] = @(coord.latitude);
            params[@"lng"] = @(coord.longitude);
        }        
        [[STNetworkManager sharedManager] GET:url
                                   parameters:params
                                      success:weakSelf.standardSuccessBlock
                                      failure:weakSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kFlowImages;
}
@end

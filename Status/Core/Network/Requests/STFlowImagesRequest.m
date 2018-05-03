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
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STFlowImagesRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        __strong STFlowImagesRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
        if ([STLocationManager locationUpdateEnabled]){
            CLLocationCoordinate2D coord = [CoreManager locationService].latestLocation.coordinate;
            params[@"lat"] = @(coord.latitude);
            params[@"lng"] = @(coord.longitude);
        }
        strongSelf.params = params;
        [[STNetworkQueueManager networkAPI] GET:url
                                   parameters:params
                                       progress:nil
                                      success:strongSelf.standardSuccessBlock
                                      failure:strongSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kFlowImages;
}
@end

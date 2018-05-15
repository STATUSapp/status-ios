//
//  STGetNearbyPostsRequest.m
//  Status
//
//  Created by Cosmin Andrus on 27/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STGetNearbyProfilesRequest.h"

@implementation STGetNearbyProfilesRequest
+ (void)getNearbyProfilesWithOffset:(NSInteger)offset
                  withCompletion:(STRequestCompletionBlock)completion
                         failure:(STRequestFailureBlock)failure{
    
    STGetNearbyProfilesRequest *request = [STGetNearbyProfilesRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.offset = offset;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetNearbyProfilesRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        __strong STGetNearbyProfilesRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
        params[@"limit"] = @(kPostsLimit);
        params[@"offset"] = @(strongSelf.offset);
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
    return kGetNearbyProfiles;
}
@end

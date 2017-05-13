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
        
        NSString *url = [self urlString];
        NSMutableDictionary *params = [self getDictParamsWithToken];
        params[@"limit"] = @(kPostsLimit);
        params[@"offset"] = @(weakSelf.offset);
        
        [[STNetworkQueueManager networkAPI] GET:url
                                    parameters:params
                                       progress:nil
                                       success:weakSelf.standardSuccessBlock
                                       failure:weakSelf.standardErrorBlock];
    };
    
    return executionBlock;
}

-(NSString *)urlString{
    return kGetNearbyProfiles;
}
@end

//
//  STGetNearbyPostsRequest.h
//  Status
//
//  Created by Cosmin Andrus on 27/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STGetNearbyProfilesRequest : STBaseRequest
@property(nonatomic, assign)NSInteger offset;
+ (void)getNearbyProfilesWithOffset:(NSInteger)offset
                  withCompletion:(STRequestCompletionBlock)completion
                         failure:(STRequestFailureBlock)failure;
@end

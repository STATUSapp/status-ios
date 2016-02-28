//
//  STUnseenPostsCountRequest.h
//  Status
//
//  Created by Cosmin Adelin Andrus on 01/06/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STUnseenPostsCountRequest : STBaseRequest
+ (void)getUnseenCountersWithCompletion:(STRequestCompletionBlock)completion
                                failure:(STRequestFailureBlock)failure;
@end

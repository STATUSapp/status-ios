//
//  STGetPostsRequest.h
//  Status
//
//  Created by Cosmin Andrus on 19/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STGetPostsRequest : STBaseRequest
@property(nonatomic, assign) NSInteger offset;
+ (void)getPostsWithOffset:(NSInteger)offset
            withCompletion:(STRequestCompletionBlock)completion
                   failure:(STRequestFailureBlock)failure;
@end

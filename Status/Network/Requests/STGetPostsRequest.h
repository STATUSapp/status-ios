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
@property(nonatomic, assign) NSInteger flowType;
+ (void)getPostsWithOffset:(NSInteger)offset
                  flowType:(NSInteger)flowType
            withCompletion:(STRequestCompletionBlock)completion
                   failure:(STRequestFailureBlock)failure;
@end

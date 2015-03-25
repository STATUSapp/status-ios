//
//  STGetUserPostsRequest.h
//  Status
//
//  Created by Cosmin Andrus on 27/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STGetUserPostsRequest : STBaseRequest
@property(nonatomic, strong)NSString *userId;
@property(nonatomic, assign)NSInteger offset;

+ (void)getPostsForUser:(NSString *)userId
             withOffset:(NSInteger)offset
         withCompletion:(STRequestCompletionBlock)completion
                failure:(STRequestFailureBlock)failure;
@end

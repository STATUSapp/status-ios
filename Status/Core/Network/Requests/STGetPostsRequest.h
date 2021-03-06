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
//only for popular flow
@property(nonatomic, strong) NSString *timeframe;
@property(nonatomic, strong) NSString *gender;
//only for hashtag flow
@property(nonatomic, strong) NSString *hashtag;
//only for top flow
@property(nonatomic, strong) NSString *topId;

+ (void)getPostsWithOffset:(NSInteger)offset
                  flowType:(NSInteger)flowType
            withCompletion:(STRequestCompletionBlock)completion
                   failure:(STRequestFailureBlock)failure;

+ (void)getPostsWithOffset:(NSInteger)offset
                  flowType:(NSInteger)flowType
                 timeFrame:(NSString *)timeframe
                    gender:(NSString *)gender
            withCompletion:(STRequestCompletionBlock)completion
                   failure:(STRequestFailureBlock)failure;
+ (void)getPostsWithOffset:(NSInteger)offset
                  flowType:(NSInteger)flowType
                   hashtag:(NSString *)hashtag
            withCompletion:(STRequestCompletionBlock)completion
                   failure:(STRequestFailureBlock)failure;
+ (void)getPostsWithOffset:(NSInteger)offset
                  flowType:(NSInteger)flowType
                     topId:(NSString *)topId
            withCompletion:(STRequestCompletionBlock)completion
                   failure:(STRequestFailureBlock)failure;
@end

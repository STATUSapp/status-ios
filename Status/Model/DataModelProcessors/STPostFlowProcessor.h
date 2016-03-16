//
//  STPostFlowProcessor.h
//  Status
//
//  Created by Cosmin Home on 28/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kNotificationPostDownloadSuccess;
extern NSString * const kNotificationPostUpdated;
extern NSString * const kNotificationPostDeleted;

typedef void (^STProcessorCompletionBlock)(NSError *error);

@class STPost;

@interface STPostFlowProcessor : NSObject
- (instancetype)initWithFlowType:(STFlowType)flowType;
- (instancetype)initWithFlowType:(STFlowType)flowType
                         userId:(NSString *)userId;
- (instancetype)initWithFlowType:(STFlowType)flowType
                         postId:(NSString *)postId;


//methods
- (NSInteger)numberOfPosts;
- (STPost *)postAtIndex:(NSInteger)index;
- (void)processPostAtIndex:(NSInteger)index;
- (void)deleteItemAtIndex:(NSInteger)index;
- (BOOL)loading;

//actions
- (void)setLikeUnlikeAtIndex:(NSInteger)index
              withCompletion:(STProcessorCompletionBlock)completion;
@end

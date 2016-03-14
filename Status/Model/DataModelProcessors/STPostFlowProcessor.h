//
//  STPostFlowProcessor.h
//  Status
//
//  Created by Cosmin Home on 28/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STBaseObj.h"

extern NSString * const kNotificationPostDownloadSuccess;

@class STPost;

@interface STPostFlowProcessor : STBaseObj
- (instancetype)initWithFlowType:(STFlowType)flowType;
- (instancetype)initWithFlowType:(STFlowType)flowType
                         userId:(NSString *)userId;
- (instancetype)initWithFlowType:(STFlowType)flowType
                         postId:(NSString *)postId;


//mothods
- (NSInteger)numberOfPosts;
- (STPost *)postAtIndex:(NSInteger)index;
- (void)processPostAtIndex:(NSInteger)index;
- (void)deleteItemAtIndex:(NSInteger)index;
- (BOOL)loading;
@end

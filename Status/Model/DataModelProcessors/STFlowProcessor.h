//
//  STPostFlowProcessor.h
//  Status
//
//  Created by Cosmin Home on 28/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kNotificationObjDownloadSuccess;
extern NSString * const kNotificationObjUpdated;
extern NSString * const kNotificationObjDeleted;
extern NSString * const kNotificationObjAdded;
extern NSString * const kNotificationShowSuggestions;

typedef void (^STProcessorCompletionBlock)(NSError *error);

@interface STFlowProcessor : NSObject
- (instancetype)initWithFlowType:(STFlowType)flowType;
- (instancetype)initWithFlowType:(STFlowType)flowType
                         userId:(NSString *)userId;
- (instancetype)initWithFlowType:(STFlowType)flowType
                         postId:(NSString *)postId;


//methods
- (NSInteger)numberOfObjects;
- (id)objectAtIndex:(NSInteger)index;
- (void)processObjectAtIndex:(NSInteger)index
           setSeenIfRequired:(BOOL)setSeenRequired;
- (void)deleteObjectAtIndex:(NSInteger)index;
- (BOOL)loading;
- (void)reloadProcessor;
- (BOOL)canGoToUserProfile;
- (BOOL)currentFlowUserIsTheLoggedInUser;

//actions
- (void)setLikeUnlikeAtIndex:(NSInteger)index
              withCompletion:(STProcessorCompletionBlock)completion;
- (void)handleBigCameraButtonActionWithUserName:(NSString *)userName;

//actions for contextual menu
- (void)askUserToUploadAtIndex:(NSInteger)index;
- (void)deletePostAtIndex:(NSInteger)index;
- (void)reportPostAtIndex:(NSInteger)index;
- (void)savePostImageLocallyAtIndex:(NSInteger)index;
- (void)sharePostOnfacebokAtIndex:(NSInteger)index;

@end

//
//  STPostFlowProcessor.h
//  Status
//
//  Created by Cosmin Home on 28/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STUserProfile;

extern NSString * const kNotificationObjDownloadSuccess;
extern NSString * const kNotificationObjUpdated;
extern NSString * const kNotificationObjDeleted;
extern NSString * const kNotificationObjAdded;
extern NSString * const kNotificationShowSuggestions;
extern NSString * const kNotificationPopularFiltersChanged;

extern NSString * const kPopularTimeframeDaily;
extern NSString * const kPopularTimeframeWeekly;
extern NSString * const kPopularTimeframeMonthly;
extern NSString * const kPopularTimeframeAllTime;

extern NSString * const kPopularGenderWomen;
extern NSString * const kPopularGenderMen;

typedef void (^STProcessorCompletionBlock)(NSError *error);

@interface STFlowProcessor : NSObject

@property (nonatomic, strong, readonly) NSString *popularTimeframe;
@property (nonatomic, strong, readonly) NSString *popularGender;

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
- (void)setCurrentOffset:(NSInteger)offset;
- (NSInteger)currentOffset;
- (NSInteger)indexOfObject:(id)object;
- (STUserProfile *)userProfile;
- (NSString *)userId;
- (BOOL)processorIsAGallery;

-(STFlowType)processorFlowType;

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

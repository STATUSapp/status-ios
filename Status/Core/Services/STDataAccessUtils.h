//
//  STDataAccessUtils.h
//  Status
//
//  Created by Cosmin Adelin Andrus on 17/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STRequests.h"

@class STShopProduct;

typedef void (^STDataAccessCompletionBlock)(NSArray *objects, NSError *error);
typedef void (^STDataUploadCompletionBlock)(NSError *error);
@interface STDataAccessUtils : NSObject

//users
+(void)getSuggestUsersForFollowType:(STFollowType)followType
                         withOffset:(NSNumber *)offset
                      andCompletion:(STDataAccessCompletionBlock)completion;
+(void)getLikesForPostId:(NSString *)postId
          withCompletion:(STDataAccessCompletionBlock)completion;
+(void)getFollowersForUserId:(NSString *)userId
                      offset:(NSNumber *)offset
          withCompletion:(STDataAccessCompletionBlock)completion;
+(void)getFollowingForUserId:(NSString *)userId
                      offset:(NSNumber *)offset
          withCompletion:(STDataAccessCompletionBlock)completion;

+(void)getFlowTemplatesWithCompletion:(STDataAccessCompletionBlock)completion;

+(void)getUserDataForUserId:(NSString *)userId
             withCompletion:(STDataAccessCompletionBlock)completion;

+(void)getConversationUsersForScope:(STSearchScopeControl)scope
                       searchString:(NSString *)searchString
                         fromOffset:(NSInteger)offset
                      andCompletion:(STDataAccessCompletionBlock)completion;

//upload stuff to server
+(void)followUsers:(NSArray *)users
    withCompletion:(STDataUploadCompletionBlock)completion;
+(void)unfollowUsers:(NSArray *)users
      withCompletion:(STDataUploadCompletionBlock)completion;


//get posts
+(void)getPostsForFlow:(STFlowType)flowType
                offset:(NSInteger)offset
        withCompletion:(STDataAccessCompletionBlock)completion;
+(void)getPostsForFlow:(STFlowType)flowType
             timeframe:(NSString *)timeframe
                gender:(NSString *)gender
                offset:(NSInteger)offset
        withCompletion:(STDataAccessCompletionBlock)completion;
+(void)getPostsForFlow:(STFlowType)flowType
               hashTag:(NSString *)hashtag
                offset:(NSInteger)offset
        withCompletion:(STDataAccessCompletionBlock)completion;
+(void)getNearbyPostsWithOffset:(NSInteger)offset
                 withCompletion:(STDataAccessCompletionBlock)completion;
+(void)getPostsForUserId:(NSString *)userId
                  offset:(NSInteger)offset
          withCompletion:(STDataAccessCompletionBlock)completion;
+(void)getPostWithPostId:(NSString *)postId
          withCompletion:(STDataAccessCompletionBlock)completion;
+ (void)commitPostWithId:(NSString *)postId
        withNewImageData:(NSData *)imageData
          withNewCaption:(NSString *)newCaption
        withShopProducts:(NSArray <STShopProduct *> *) shopProducts
          withCompletion:(STDataAccessCompletionBlock)completion;
+ (void)editPostWithId:(NSString *)postId
      withNewImageData:(NSData *)imageData
        withNewCaption:(NSString *)newCaption
      withShopProducts:(NSArray <STShopProduct *> *) shopProducts
        withCompletion:(STDataAccessCompletionBlock)completion;

//suggestion products
+(void)getSuggestedProductsWithPostId:(NSString *)postId
                       withCompletion:(STDataAccessCompletionBlock)completion;
+(void)getSimilarProductsWithPostId:(NSString *)postId
                       suggestionId:(NSString *)suggestionId
                     withCompletion:(STDataAccessCompletionBlock)completion;
+(void)transformSuggestionWithPostId:(NSString *)postId
                        suggestionId:(NSString *)suggestionId
                      withCompletion:(STDataAccessCompletionBlock)completion;

//upload post stuff
+ (void)setPostLikeUnlikeWithPostId:(NSString *)postId
                     withCompletion:(STDataUploadCompletionBlock)completion;
+ (void)deletePostWithId:(NSString *)postId
          withCompletion:(STDataUploadCompletionBlock)completion;
+ (void)reportPostWithId:(NSString *)postId
          withCompletion:(STDataUploadCompletionBlock)completion;
+ (void)inviteUserToUpload:(NSString *)userID
              withUserName:(NSString *)userName
            withCompletion:(STDataUploadCompletionBlock)completion;

//get notifications
+ (void)getNotificationsWithCompletion:(STDataAccessCompletionBlock)completion;

//get user profile
+ (void)getUserProfileForUserId:(NSString *)userId
                  andCompletion:(STDataAccessCompletionBlock)completion;

//tag products
+ (void)getCatalogParentEntitiesWithCompletion:(STDataAccessCompletionBlock)completion;
+ (void)getCatalogCategoriesForParentCategoryId:(NSString *) parentCategoryId
                                   andPageIndex:(NSInteger)pageIndex
                                 withCompletion:(STDataAccessCompletionBlock)completion;
+ (void)getUsedCatalogCategoriesAtPageIndex:(NSInteger)pageIndex
                             withCompletion:(STDataAccessCompletionBlock)completion;
+ (void)getSuggestionsForCategory:(NSString *)categoryId
                         andBrand:(NSString *)brandId
                     andPageIndex:(NSInteger)pageIndex
                    andCompletion:(STDataAccessCompletionBlock)completion;
+ (void)getUsedSuggestionsForCategory:(NSString *)categoryId
                         andPageIndex:(NSInteger)pageIndex
                        andCompletion:(STDataAccessCompletionBlock)completion;
+ (void)getProductsByBarcode:(NSString *)barcodeString
                andPageIndex:(NSInteger)pageIndex
               andCompletion:(STDataAccessCompletionBlock)completion;

//commissions
+ (void)getUserCommissionsWithCompletion:(STDataAccessCompletionBlock)completion;
+ (void)withdrawCommissionsWithCompletion:(STDataUploadCompletionBlock)completion;

//withdrawn
+ (void)getUserWithdrawDetailsWithCompletion:(STDataAccessCompletionBlock)completion;
+ (void)postUserWithdrawDetails:(STWithdrawDetailsObj *)withdrawObj
                 withCompletion:(STDataUploadCompletionBlock)completion;

@end

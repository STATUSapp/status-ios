//
//  STDataAccessUtils.h
//  Status
//
//  Created by Cosmin Adelin Andrus on 17/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STRequests.h"

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
+(void)getNearbyPostsWithOffset:(NSInteger)offset
                 withCompletion:(STDataAccessCompletionBlock)completion;
+(void)getPostsForUserId:(NSString *)userId
                  offset:(NSInteger)offset
          withCompletion:(STDataAccessCompletionBlock)completion;
+(void)getPostWithPostId:(NSString *)postId
          withCompletion:(STDataAccessCompletionBlock)completion;
+ (void)editPpostWithId:(NSString *)postId
       withNewImageData:(NSData *)imageData
         withNewCaption:(NSString *)newCaption
         withCompletion:(STDataAccessCompletionBlock)completion;

//upload post stuff
+(void)setPostSeenForPostId:(NSString *)postId
             withCompletion:(STDataUploadCompletionBlock)completion;
+ (void)setPostLikeUnlikeWithPostId:(NSString *)postId
                     withCompletion:(STDataUploadCompletionBlock)completion;
+ (void)deletePostWithId:(NSString *)postId
          withCompletion:(STDataUploadCompletionBlock)completion;
+ (void)reportPostWithId:(NSString *)postId
          withCompletion:(STDataUploadCompletionBlock)completion;
+ (void)updatePostWithId:(NSString *)postId
          withNewCaption:(NSString *)newCaption
          withCompletion:(STDataUploadCompletionBlock)completion;
+ (void)inviteUserToUpload:(NSString *)userID
              withUserName:(NSString *)userName
            withCompletion:(STDataUploadCompletionBlock)completion;

//get notifications
+ (void)getNotificationsWithCompletion:(STDataAccessCompletionBlock)completion;

//get user profile
+ (void)getUserProfileForUserId:(NSString *)userId
                  andCompletion:(STDataAccessCompletionBlock)completion;
@end

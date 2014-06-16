//
//  STConstants.h
//  Status
//
//  Created by Andrus Cosmin on 16/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PAGGING_ENABLED 1
#define  POSTS_PAGGING 10
#pragma mark - Enums

typedef NS_ENUM(NSUInteger,STFlowType){
    STFlowTypeAllPosts = 0,
    STFlowTypeDiscoverNearby,
    STFlowTypeUserProfile,
    STFlowTypeMyProfile,
    STFlowTypeSinglePost
};

typedef NS_ENUM(NSUInteger,STWebservicesCodes){
    STWebservicesSuccesCod=200,
    STWebservicesNeedRegistrationCod=404,
    STWebservicesFounded = 302
};

typedef NS_ENUM(NSUInteger,STNotificationType){
    STNotificationTypeLike = 1,
    STNotificationTypeInvite,
    STNotificationTypeUploaded
};


#pragma mark - Constant Strings

extern NSString *const kBaseURL;
extern NSString *const kBasePhotoDownload;

extern NSString *const kGetPosts;
extern NSString *const kLoginUser;
extern NSString *const kRegisterUser;
extern NSString *const kPostPhoto;
extern NSString *const kSetPostLiked;
extern NSString *const kReport_Post;
extern NSString *const kGetUserPosts;
extern NSString *const kSetPostSeen;
extern NSString *const kGetPostLikes;
extern NSString *const kSetApnToken;
extern NSString *const kGetPost;
extern NSString *const kGetNotifications;
extern NSString *const kDeletePost;
extern NSString *const kInviteToUpload;
extern NSString *const kSetUserLocation;
extern NSString *const kGetUnreadNotificationsCount;
extern NSString *const kGetNearbyPosts;

#pragma mark - Local Notifications

extern NSString *const STNotificationBadgeValueDidChanged;
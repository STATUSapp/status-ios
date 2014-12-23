//
//  STConstants.h
//  Status
//
//  Created by Andrus Cosmin on 16/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define USE_PRODUCTION_SERVER 0
#define APP_URL_STRING        @"itms-apps://itunes.apple.com/app/id841855995"
#define APP_REVIEW_URL_STRING @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=841855995&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"

#pragma mark - Enums

typedef NS_ENUM(NSUInteger,STFlowType){
    STFlowTypeAllPosts = 0,
    STFlowTypeDiscoverNearby,
    STFlowTypeUserProfile,
    STFlowTypeMyProfile,
    STFlowTypeSinglePost
};

typedef NS_ENUM(NSUInteger, STInterstitialType){
    STInterstitialTypeAds = 0,
    STInterstitialTypeRemoveAds,
    STInterstitialTypeInviter
};

typedef NS_ENUM(NSUInteger,STWebservicesCodes){
    STWebservicesSuccesCod=200,
    STWebservicesNeedRegistrationCod=404,
    STWebservicesFounded = 302
};

typedef NS_ENUM(NSUInteger,STNotificationType){
    STNotificationTypeLike = 1,
    STNotificationTypeInvite = 2,
    STNotificationTypeUploaded = 3,
    STNotificationTypeChatMessage = 4, //not used , but to be consistent with the web
    STNotificationTypePhotosWaiting = 5,
    STNotificationTypeNewUserJoinsStatus = 6,
    STNotificationTypeGuaranteedViewsForNextPhoto = 7,
    STNotificationType5DaysUploadNewPhoto = 8
};

typedef NS_ENUM(NSUInteger,STWebSockerStatus){
    STWebSockerStatusClosed =0,
    STWebSockerStatusConnecting,
    STWebSockerStatusConnected
};

typedef NS_ENUM(NSUInteger,STConnectionStatus){
    STConnectionStatusOff =0,
    STConnectionStatusOn
};

typedef NS_ENUM(NSUInteger,STSearchScopeControl){
    STSearchControlAll =0,
    STSearchControlNearby,
    STSearchControlRecent
};

#pragma mark - Constant Strings

extern NSString *const kBaseURL;
extern NSString *const kBasePhotoDownload;
extern NSString *const kChatSocketURL;
extern NSString *const kReachableURL;
extern int const kChatPort;

extern NSString *const kSTAdUnitID;

extern NSInteger const kHTTPErrorNoConnection;
extern NSInteger const kPostsLimit;
extern NSInteger const kStartLoadOffset;

extern NSString *const kGetPosts;
extern NSString *const kLoginUser;
extern NSString *const kRegisterUser;
extern NSString *const kPostPhoto;
extern NSString *const kSetPostLiked;
extern NSString *const kUpdatePost;
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
extern NSString *const kGetAllUsers;
extern NSString *const kGetNearby ;
extern NSString *const kGetRecent;
extern NSString *const kGetUserInfo;
extern NSString *const kGetUserSettings;
extern NSString *const kSetUserSetting;
extern NSString *const kGetUserProfile;

extern NSString *const kMATAdvertiserID;
extern NSString *const kMATConversionKey;

extern NSString *const kRemoveAdsInAppPurchaseProductID;
extern NSString *const IAPHelperProductPurchasedNotification;
extern NSString *const IAPHelperProductPurchasedFailedNotification;
extern NSString *const IAPHelperRestorePurchaseFailedNotification;

#pragma mark - Local Notifications

extern NSString *const STNotificationBadgeValueDidChanged;
extern NSString *const STUnreadMessagesValueDidChanged;
extern NSString *const STChatControllerAuthenticate;
extern NSString *const STFacebookPickerNotification;
extern NSString *const STLoadImageNotification;

#pragma mark - Invite Friends

extern NSString *const STInviteText;
extern NSString *const STInviteLink;

#pragma mark - Numeric constants

extern NSInteger const STMaximumSizeInBytesForUpload;

#pragma mark - Settings

extern NSString *const STSettingsDictKey;
extern NSString *const STNotificationsLikesKey;
extern NSString *const STNotificationsMessagesKey;
extern NSString *const STNotificationsUploadNewPhotoKey;
extern NSString *const STNotificationsFriendJoinStatusKey;
extern NSString *const STNotificationsPhotosWaitingKey;
extern NSString *const STNotificationsExtraLikesKey;

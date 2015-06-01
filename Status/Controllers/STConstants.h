//
//  STConstants.h
//  Status
//
//  Created by Andrus Cosmin on 16/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define USE_PRODUCTION_SERVER 0
#define APP_STORE_ID          @"841855995"
#define APP_URL_STRING        @"itms-apps://itunes.apple.com/app/id841855995"
#define APP_REVIEW_URL_STRING @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=841855995&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#pragma mark - Enums

typedef NS_ENUM(NSUInteger,STFlowType){
    STFlowTypeHome = 0,
    STFlowTypeDiscoverNearby,
    STFlowTypeUserGallery,
    STFlowTypeMyGallery,
    STFlowTypeSinglePost,
    STFlowTypePopular,
    STFlowTypeRecent,
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
    STConnectionStatusNotSet = 0,
    STConnectionStatusOff = -1,
    STConnectionStatusOn = 1
};

typedef NS_ENUM(NSUInteger,STSearchScopeControl){
    STSearchControlAll =0,
    STSearchControlNearby,
    STSearchControlRecent
};

typedef NS_ENUM(NSUInteger, STUserStatus){
    STUserStatusActive,
    STUserStatusAway,
    STUserStatusOffline
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
extern NSString *const kGetHomePosts;
extern NSString *const kGetRecentPosts;
extern NSString *const kLoginUser;
extern NSString *const kRegisterUser;
extern NSString *const kPostPhoto;
extern NSString *const kSetPostLiked;
extern NSString *const kUpdatePost;
extern NSString *const kUpdatePhotoCaption;
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
extern NSString *const kGetNearbyProfiles;
extern NSString *const kGetAllUsers;
extern NSString *const kGetNearby ;
extern NSString *const kGetRecent;
extern NSString *const kGetUserInfo;
extern NSString *const kGetUserSettings;
extern NSString *const kSetUserSetting;
extern NSString *const kGetUserProfile;
extern NSString *const kUpdateUserProfile;
extern NSString *const kEditCaption;
extern NSString *const kSetProfilePicture;
extern NSString *const kGetSuggestUsers;
extern NSString *const kFollowUsers;
extern NSString *const kUnfollowUsers;
extern NSString *const kUnseenPostsCount;

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
extern NSString *const STNotificationsFollowersKey;

#pragma mark - UserProfile

extern NSString * const kBirthdayKey;
extern NSString * const kFirstNameKey;
extern NSString * const kFulNameKey;
extern NSString * const kLastActiveKey;
extern NSString * const kLastNameKey;
extern NSString * const kLocationKey;
extern NSString * const kLocationLatitudeKey;
extern NSString * const kLocationLongitudeKey;
extern NSString * const kNumberOfPostsKey;
extern NSString * const kProfilePhotoLinkKey;
extern NSString * const kBioKey;

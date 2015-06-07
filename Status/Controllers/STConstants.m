//
//  STConstants.m
//  Status
//
//  Created by Andrus Cosmin on 16/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STConstants.h"

# pragma mark - Ammadeuss Dev
//NSString *const kBaseURL = @"http://dev.simplebig.ro/status/api/";
//NSString *const kBasePhotoDownload = @"http://dev.simplebig.ro/status/media/";

#if USE_PRODUCTION_SERVER

#pragma mark - Production Server
NSString *const kBaseURL = @"http://api.getstatusapp.co/api/";
NSString *const kBasePhotoDownload = @"http://api.getstatusapp.co/media/";
NSString *const kChatSocketURL = @"http://api.getstatusapp.co";
NSString *const kReachableURL = @"api.getstatusapp.co";
int const kChatPort = 9002;

#else

#pragma mark - Denis Dev
NSString *const kBaseURL = @"http://dev.getstatusapp.co/api/";
NSString *const kBasePhotoDownload = @"http://dev.getstatusapp.co/media/";
NSString *const kChatSocketURL = @"http://dev.getstatusapp.co";
NSString *const kReachableURL = @"dev.getstatusapp.co";
int const kChatPort = 9003;

#endif

NSInteger const kHTTPErrorNoConnection = 447;
NSInteger const kPostsLimit = 20;
NSInteger const kStartLoadOffset = 10;
#pragma mark - Denis Dev1
//NSString *const kBaseURL = @"http://status.nece.me/api/";
//NSString *const kBasePhotoDownload = @"http://status.nece.me/media/";


NSString *const kSTAdUnitID = @"ca-app-pub-2971682460090432/5255730305";

//NSString *const kGetPosts = @"get_posts2";
NSString *const kGetPosts = @"get_posts";
NSString *const kGetHomePosts = @"Get_Home_Posts";
NSString *const kGetRecentPosts = @"Get_Recent_Posts";
NSString *const kLoginUser = @"login_user";
NSString *const kRegisterUser = @"register_user";
NSString *const kPostPhoto = @"post_photo";
NSString *const kUpdatePost = @"update_photo";
NSString *const kUpdatePhotoCaption = @"set_post_caption";
NSString *const kSetPostLiked = @"set_post_like_unlike";
NSString *const kReport_Post = @"report_post";
NSString *const kGetUserPosts = @"get_user_posts";
NSString *const kSetPostSeen = @"set_post_seen";
NSString *const kGetPostLikes = @"get_post_likes";
NSString *const kSetApnToken = @"set_apn_token";
NSString *const kGetPost = @"get_post";
NSString *const kGetNotifications = @"get_notifications";
NSString *const kDeletePost = @"delete_photo";
NSString *const kInviteToUpload = @"invite_to_upload";
NSString *const kSetUserLocation = @"set_user_location";
NSString *const kGetUnreadNotificationsCount = @"get_unread_notifications_count";
NSString *const kGetNearbyProfiles = @"get_nearby_profiles";
NSString *const kGetAllUsers = @"get_all_users";
NSString *const kGetNearby = @"get_nearby_users";
NSString *const kGetRecent = @"get_recent_users";
NSString *const kGetUserInfo = @"get_user_info";
NSString *const kGetUserSettings = @"get_user_settings";
NSString *const kSetUserSetting = @"set_user_setting";
NSString *const kGetUserProfile = @"get_user_profile";
NSString *const kUpdateUserProfile = @"set_user_profile";
NSString *const kEditCaption = @"set_post_caption";
NSString *const kSetProfilePicture =  @"upload_user_photo";
NSString *const kGetSuggestUsers = @"Get_Suggest_Users";
NSString *const kFollowUsers = @"Follow";
NSString *const kUnfollowUsers = @"Unfollow";
NSString *const kUnseenPostsCount = @"Get_Unseen_Posts_Count";

NSString *const kMATAdvertiserID = @"21414";
NSString *const kMATConversionKey = @"9b85f596c75ed11ac4dd72cd8a392ca8";

NSString *const kRemoveAdsInAppPurchaseProductID = @"2";
NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";
NSString *const IAPHelperProductPurchasedFailedNotification = @"IAPHelperProductPurchasedFailedNotification";
NSString *const IAPHelperRestorePurchaseFailedNotification = @"IAPHelperRestorePurchaseFailedNotification";

#pragma mark - Local Notifications

NSString *const STNotificationBadgeValueDidChanged = @"STNotificationBadgeValueDidChanged";
NSString *const STUnreadMessagesValueDidChanged = @"STUnreadMessagesValueDidChanged";
NSString *const STChatControllerAuthenticate = @"STChatControllerAuthenticate";
NSString *const STFacebookPickerNotification = @"STFacebookPickerNotification";
NSString *const STLoadImageNotification = @"STLoadImageNotification";


#pragma mark - Invite Friends

NSString *const STInviteText = @"I'm sending you one of my 3 special friend invites on Get STATUS.\nYou can chat with happy and positive people around you, discover and share wonderful moments and receive hundreds of likes.";
NSString *const STInviteLink = @"http://bit.ly/Njw1k4";


#pragma mark - Numeric constants

NSInteger const STMaximumSizeInBytesForUpload = 3145728;  // 3 MB


#pragma mark - Settings

NSString *const STSettingsDictKey = @"STSettingsDictKey";
NSString *const STNotificationsLikesKey = @"notifications_likes";
NSString *const STNotificationsMessagesKey = @"notifications_messages";
NSString *const STNotificationsUploadNewPhotoKey = @"notifications_upload_a_new_photo";
NSString *const STNotificationsFriendJoinStatusKey = @"notifications_a_friend_joins_status";
NSString *const STNotificationsPhotosWaitingKey = @"notifications_photos_waiting_for_you";
NSString *const STNotificationsExtraLikesKey = @"notifications_earn_extra_likes";
NSString *const STNotificationsFollowersKey = @"notifications_new_follower";



//
//  STConstants.m
//  Status
//
//  Created by Andrus Cosmin on 16/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STConstants.h"

#if USE_PRODUCTION_SERVER

#pragma mark - Production Server

//NSString *const kBaseURL = @"http://api.getstatusapp.co/api/";
//NSString *const kReachableURL = @"api.getstatusapp.co";

//NSString *const kBaseURL = @"https://api.getstatusapp.co/api/v1/";
//NSString *const kReachableURL = @"api.getstatusapp.co";

NSString *const kBaseURL = @"https://getstatus.co/api/v1/";
NSString *const kNoApiBaseURL = @"https://getstatus.co/";
NSString *const kReachableURL = @"getstatus.co";

#else

NSString *const kBaseURL = @"http://139.59.128.34/api/v1/";
NSString *const kNoApiBaseURL = @"http://139.59.128.34/";
NSString *const kReachableURL = @"139.59.128.34";
//NSString *const kBaseURL = @"http://10.49.100.81:8000/api/v1/";
//NSString *const kReachableURL = @"10.49.100.81";


//NSString *const kBaseURL = @"http://ec2-52-86-4-15.compute-1.amazonaws.com/api/";
//NSString *const kReachableURL = @"ec2-52-86-4-15.compute-1.amazonaws.com";

#endif

NSInteger const kHTTPErrorNoConnection = 447;

#ifdef DEBUG

NSInteger const kPostsLimit = 15;
NSInteger const kStartLoadOffset = 5;
NSInteger const kCatalogDownloadPageSize = 50;
NSInteger const kCatalogBrandsPageSize = 1000;

#else

NSInteger const kPostsLimit = 20;
NSInteger const kStartLoadOffset = 10;
NSInteger const kCatalogDownloadPageSize = 50;
NSInteger const kCatalogBrandsPageSize = 1000;

#endif


NSString *const kSTAdUnitID = @"ca-app-pub-2971682460090432/5255730305";

NSString *const kGetPosts = @"get_posts";
NSString *const kGetHomePosts = @"Get_Home_Posts";
NSString *const kGetRecentPosts = @"Get_Recent_Posts";
NSString *const kGetPostsByHashTag = @"get_posts_by_hashtag";
NSString *const kGetPostsByTop = @"get_top_posts";
NSString *const kLoginUser = @"login_user";
NSString *const kInstagramLogin = @"instagram_login";
NSString *const kRegisterUser = @"register_user";
NSString *const kPostPhoto = @"post_photo";
NSString *const kUpdatePost = @"update_photo";
NSString *const kSetPostLiked = @"set_post_like_unlike";
NSString *const kReport_Post = @"report_post";
NSString *const kGetUserPosts = @"get_user_posts";
NSString *const kGetPostLikes = @"get_post_likes";
NSString *const kGetTopPost = @"get_top_post";
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
NSString *const kFollowUsers = @"Follow";
NSString *const kUnfollowUsers = @"Unfollow";
NSString *const kUnseenPostsCount = @"Get_Unseen_Posts_Count";
NSString *const kFlowImages = @"get_flow_image";
NSString *const kGetHostnamePortChat = @"get_hostname_port_chat";
NSString *const kInviteFriendsByEmail = @"invite_friends_by_email";
NSString *const kSyncContacts = @"sync_contacts";
NSString *const kGetFriendsYouShouldFollow = @"friends_you_should_follow";
NSString *const kGetPeopleYouShouldFollow = @"people_you_should_follow";
NSString *const kGetFriendsPeopleYouShouldFollow = @"frieds_people_you_should_follow";
NSString *const kUploadShopProduct = @"catalog/products/create";
NSString *const kGetCatalogParentCategories = @"catalog/root_categories";
NSString *const kGetCatalofCategories = @"catalog/categories/all";
NSString *const kGetUsedCatalofCategories = @"catalog/categories/used";
NSString *const kGetBrands = @"catalog/brands";
NSString *const kGetSuggestions = @"catalog/products/all";
NSString *const kGetUsedSuggestions = @"catalog/products/used";
NSString *const kGetProductsByBarcode = @"catalog/products/by_barcode";
NSString *const kProductSuggest = @"catalog/products/suggest";
NSString *const kGetBrandsWithProducts = @"catalog/categoryBrands";
NSString *const kUserCommissions = @"users/commissions";
NSString *const kUserWithdrawnDetails = @"users/details";
NSString *const kUserWithdrawnUpdateDetails = @"users/details/update";
//TODO: change this when the API will be ready
NSString *const kGetImageSuggestions = @"get_post_suggestions";
NSString *const kGetSimilarProducts = @"get_post_similar_suggestions";
NSString *const kTransformSuggestions = @"transform_post_suggestions";
NSString *const kDeleteAccount = @"delete_profile";
NSString *const kSendLogs = @"__log";
NSString *const kGetInstagramClientToken = @"get_instagram_client_token";

NSString *const kAPIKey = @"API";
NSString *const kErrorCodeKey = @"error_code";
NSString *const kImageLinkKey = @"image_link";

NSString *const kMATAdvertiserID = @"21414";
NSString *const kMATConversionKey = @"9b85f596c75ed11ac4dd72cd8a392ca8";

NSString *const kRemoveAdsInAppPurchaseProductID = @"2";
NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";
NSString *const IAPHelperProductPurchasedFailedNotification = @"IAPHelperProductPurchasedFailedNotification";
NSString *const IAPHelperRestorePurchaseFailedNotification = @"IAPHelperRestorePurchaseFailedNotification";

#pragma mark - Local Notifications

NSString *const STNotificationShouldGoToTop = @"STNotificationShouldGoToTop";
NSString *const STNotificationBadgeValueDidChanged = @"STNotificationBadgeValueDidChanged";
NSString *const STUnreadMessagesValueDidChanged = @"STUnreadMessagesValueDidChanged";
NSString *const STChatControllerAuthenticate = @"STChatControllerAuthenticate";
NSString *const STFacebookPickerNotification = @"STFacebookPickerNotification";
NSString *const STLoadImageNotification = @"STLoadImageNotification";
NSString *const STPostPoolObjectUpdatedNotification = @"STPostPoolObjectUpdatedNotification";
NSString *const STPostPoolNewObjectNotification = @"STPostPoolNewObjectNotification";
NSString *const STPostPoolObjectDeletedNotification = @"STPostPoolObjectDeletedNotification";
NSString *const STProfilePoolObjectUpdatedNotification = @"STProfilePoolObjectUpdatedNotification";
NSString *const STProfilePoolNewObjectNotification = @"STProfilePoolNewObjectNotification";
NSString *const STProfilePoolObjectDeletedNotification = @"STProfilePoolObjectDeletedNotification";
NSString *const STUserPoolObjectUpdatedNotification = @"STUserPoolObjectUpdatedNotification";

NSString *const STPostNewImageUploaded = @"STPostNewImageUploaded";
NSString *const STPostImageWasEdited = @"STPostImageWasEdited";
NSString *const STPostCaptionWasEdited = @"STPostCaptionWasEdited";

NSString *const STFooterFlowsNotification = @"STFooterFlowsNotification";
NSString *const STHomeFlowShouldBeReloadedNotification = @"STHomeFlowShouldBeReloadedNotification";
NSString *const STMyProfileFlowShouldBeReloadedNotification = @"STMyProfileFlowShouldBeReloadedNotification";
NSString *const STNotificationsShouldBeReloaded = @"STNotificationsShouldBeReloaded";

NSString *const STNotificationSelectNotificationsScreen = @"STSelectNotificationsScreenNotification";
NSString *const STNotificationSelectChatScreen = @"STSelectChatScreenNotification";

#pragma mark - Notification User Info Keys

NSString *const kPostIdKey = @"key_post_id";
NSString *const kImageKey = @"key_image";
NSString *const kImageUrlKey = @"key_image_url";
NSString *const kFlowTypeKey = @"flow_type_key";
NSString *const kUserIdKey = @"user_id_key";
NSString *const kImageSizeKey = @"image_size_key";
NSString *const kOffsetKey = @"offset_key";
NSString *const kSelectedTabBarKey = @"selected_index";
NSString *const kAnimatedTabBarKey = @"animated";
NSString *const kManualLogoutKey = @"manual_logout_key";

#pragma mark - Numeric constants

#pragma mark - Settings

NSString *const STSettingsDictKey = @"STSettingsDictKey";
NSString *const STNotificationsLikesKey = @"notifications_likes";
NSString *const STNotificationsMessagesKey = @"notifications_messages";
NSString *const STNotificationsUploadNewPhotoKey = @"notifications_upload_a_new_photo";
NSString *const STNotificationsFriendJoinStatusKey = @"notifications_a_friend_joins_status";
NSString *const STNotificationsPhotosWaitingKey = @"notifications_photos_waiting_for_you";
NSString *const STNotificationsExtraLikesKey = @"notifications_earn_extra_likes";
NSString *const STNotificationsFollowersKey = @"notifications_new_follower";
NSString *const STNotificationsTBDPKey = @"notifications_top_main";
NSString *const STNotificationsHintTBDPKey = @"notifications_top_hint";
NSString *const STNotificationsSharePostTBDPKey = @"notifications_top_share";

#pragma mark - Login Constants

NSString *const kNotificationUserDidLoggedIn = @"NotificationUserDidLoggedIn";
NSString *const kNotificationUserDidLoggedOut = @"NotificationUserDidLoggedOut";
NSString *const kNotificationSessionExpired = @"NotificationSessionExpired";

#pragma mark - Facebook Login Constants

NSString *const kNotificationFacebokDidLogin = @"NotificationFacebokDidLogin";
NSString *const kNotificationFacebokDidLogout = @"NotificationFacebokDidLogout";

#pragma mark - snack bar action notification

NSString *const kNotificationSnackBarAction = @"NotificationSnackBarAction";
NSString *const kNotificationSnackBarActionTypeKey = @"NotificationSnackBarActionTypeKey";
NSString *const kChatMinimumVersion = @"1.0.4";



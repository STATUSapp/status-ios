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
#pragma mark - Production Server
//NSString *const kBaseURL = @"http://status.glazeon.com/api/";
//NSString *const kBasePhotoDownload = @"http://status.glazeon.com/media/";
#pragma mark - Denis Dev
NSString *const kBaseURL = @"http://dev.getstatusapp.co/api/";
NSString *const kBasePhotoDownload = @"http://dev.getstatusapp.co/media/";

NSString *const kSTAdUnitID = @"ca-app-pub-2971682460090432/5255730305";

//NSString *const kGetPosts = @"get_posts2";
NSString *const kGetPosts = @"get_posts";
NSString *const kLoginUser = @"login_user";
NSString *const kRegisterUser = @"register_user";
NSString *const kPostPhoto = @"post_photo";
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
NSString *const kGetNearbyPosts = @"get_nearby_post";
NSString *const kGetAllUsers = @"get_all_users";


NSString *const kMATAdvertiserID = @"21414";
NSString *const kMATConversionKey = @"9b85f596c75ed11ac4dd72cd8a392ca8";

NSString *const kRemoveAdsInAppPurchaseProductID = @"1";
NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";

#pragma mark - Local Notifications

NSString *const STNotificationBadgeValueDidChanged = @"STNotificationBadgeValueDidChanged";
NSString *const STUnreadMessagesValueDidChanged = @"STUnreadMessagesValueDidChanged";

#pragma mark - Invite Friends

NSString *const STInviteText = @"I'm sending you one of my 3 special friend invites on Get STATUS.\nYou can chat with happy and positive people around you, discover and share wonderful moments and receive hundreds of likes.";
NSString *const STInviteLink = @"http://bit.ly/Njw1k4";
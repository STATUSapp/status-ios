//
//  STConstants.m
//  Status
//
//  Created by Andrus Cosmin on 16/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STConstants.h"

//NSString *const kBaseURL = @"http://dev.simplebig.ro/status/api/";
//NSString *const kBasePhotoDownload = @"http://dev.simplebig.ro/status/media/";
NSString *const kBaseURL = @"http://status.glazeon.com/api/";
NSString *const kBasePhotoDownload = @"http://status.glazeon.com/media/";

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

#pragma mark - Local Notifications

NSString *const STNotificationBadgeValueDidChanged = @"STNotificationBadgeValueDidChanged";
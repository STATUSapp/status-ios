//
//  STLikeUser.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 31/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STLikeUser.h"

@implementation STLikeUser
+(STLikeUser *)likeUserWithDict:(NSDictionary *)dict{
    STLikeUser *lu = [STLikeUser new];
    lu.infoDict = dict;
    lu.appVersion = dict[@"app_version"];
    lu.followedByCurrentUser = dict[@"followed_by_current_user"];
    lu.thumbnail = dict[@"full_photo_link"];
    lu.uuid = dict[@"user_id"];
    lu.userName = dict[@"user_name"];
    return lu;
}

@end

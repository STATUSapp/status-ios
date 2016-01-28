//
//  STLikeUser.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 31/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STListUser.h"
#import "NSString+MD5.h"

@implementation STListUser
+(STListUser *)likeUserWithDict:(NSDictionary *)dict{
    STListUser *lu = [STListUser new];
    lu.infoDict = dict;
    lu.appVersion = dict[@"app_version"];
    lu.followedByCurrentUser = dict[@"followed_by_current_user"];
    lu.thumbnail = dict[@"full_photo_link"];
    
    if (lu.thumbnail == nil) {
        lu.thumbnail = dict[@"user_photo"];
    }
    
    lu.uuid = [NSString stringFromDictValue:dict[@"user_id"]];
    lu.userName = dict[@"user_name"];
    return lu;
}

@end

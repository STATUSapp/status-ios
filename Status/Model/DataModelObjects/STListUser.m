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
+(STListUser *)listUserWithDict:(NSDictionary *)dict{
    STListUser *lu = [STListUser new];
    lu.infoDict = dict;
    lu.appVersion = [CreateDataModelHelper validObjectFromDict:dict forKey:@"app_version"];
    lu.followedByCurrentUser = dict[@"followed_by_current_user"];
    lu.thumbnail = [CreateDataModelHelper validObjectFromDict:dict forKey:@"full_photo_link"];
    
    if (lu.thumbnail == nil) {
        lu.thumbnail = [CreateDataModelHelper validObjectFromDict:dict forKey:@"user_photo"];
    }
    
    lu.uuid = [CreateDataModelHelper validStringIdentifierFromValue:dict[@"user_id"]];
    lu.userName = [CreateDataModelHelper validObjectFromDict:dict forKey:@"user_name"];
    return lu;
}

@end

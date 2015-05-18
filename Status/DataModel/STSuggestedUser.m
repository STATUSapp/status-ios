//
//  STSuggestedUser.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 17/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STSuggestedUser.h"

@implementation STSuggestedUser
+(STSuggestedUser *)suggestedUserWithDict:(NSDictionary *)dict{
    STSuggestedUser *sUser = [STSuggestedUser new];
    sUser.uuid = dict[@"user_id"];
    sUser.followedByCurrentUser = [dict[@"followed_by_current_user"] boolValue];
    sUser.userName = dict[@"user_name"];
    sUser.thumbnail = dict[@"user_photo"];
    
    return sUser;
}
@end

//
//  STSuggestedUser.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 17/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STSuggestedUser.h"
#import "NSString+MD5.h"

@implementation STSuggestedUser
+(STSuggestedUser *)suggestedUserWithDict:(NSDictionary *)dict{
    STSuggestedUser *sUser = [STSuggestedUser new];
    sUser.uuid = [NSString stringFromDictValue:dict[@"user_id"]];
    sUser.followedByCurrentUser = dict[@"followed_by_current_user"];
    sUser.userName = dict[@"user_name"];
    sUser.thumbnail = dict[@"user_photo"];
    
    return sUser;
}
@end

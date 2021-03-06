//
//  STSuggestedUser.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 17/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STSuggestedUser.h"
#import "CreateDataModelHelper.h"

@implementation STSuggestedUser
+(STSuggestedUser *)suggestedUserWithDict:(NSDictionary *)dict{
    STSuggestedUser *sUser = [STSuggestedUser new];
    sUser.infoDict = dict;
    sUser.uuid = [CreateDataModelHelper validStringIdentifierFromValue:dict[@"user_id"]];
    sUser.followedByCurrentUser = dict[@"followed_by_current_user"];
    sUser.userName = [CreateDataModelHelper validObjectFromDict:dict forKey:@"user_name"];
    sUser.thumbnail = [CreateDataModelHelper validObjectFromDict:dict forKey:@"user_photo"];
    NSString *userGender = [CreateDataModelHelper validObjectFromDict:dict forKey:@"user_gender"];
    sUser.gender = [sUser genderFromString:userGender];

    return sUser;
}

- (NSString *)genderImage{
    return [self genderImageNameForGender:self.gender];
}
@end

//
//  STUserProfile.m
//  Status
//
//  Created by Silviu Burlacu on 07/06/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STUserProfile.h"
#import "NSDate+Additions.h"
#import "STImageCacheController.h"

@implementation STUserProfile

+ (instancetype)userProfileWithDict:(NSDictionary *)userDict {
    STUserProfile * userProfile = [[STUserProfile alloc] init];
    [userProfile setupWithDict:userDict];
    return userProfile;
}

- (void)setupWithDict:(NSDictionary *)userDict {
    self.uuid = [CreateDataModelHelper validStringIdentifierFromValue:userDict[@"user_id"]];
    self.appVersion = [CreateDataModelHelper validObjectFromDict:userDict forKey:@"app_version"];
    self.infoDict = userDict;
    _bio = [CreateDataModelHelper validObjectFromDict:userDict forKey:@"bio"];
    _birthday = [NSDate dateFromServerDate:[CreateDataModelHelper validObjectFromDict:userDict forKey:@"birthday"]];
    
    NSString * lastSeen = [CreateDataModelHelper validObjectFromDict:userDict forKey:@"last_seen"];
    
    if ([lastSeen isEqualToString:@"1"]) {
        _isActive = YES;
    } else if ([lastSeen isEqualToString:@"0"]) {
        _wasNeverActive = YES;
    } else {
        _lastActive = [NSDate dateFromServerDateTime:lastSeen];
    }
    
    _firstname = [CreateDataModelHelper validObjectFromDict:userDict forKey:@"firstname"];
    _fullName = [CreateDataModelHelper validObjectFromDict:userDict forKey:@"fullname"];
    _lastName = [CreateDataModelHelper validObjectFromDict:userDict forKey:@"lastname"];
    
    _homeLocation = [CreateDataModelHelper validObjectFromDict:userDict forKey:@"location"];
    _latitude = [CreateDataModelHelper validObjectFromDict:userDict forKey:@"location_lat"];
    _longitude = [CreateDataModelHelper validObjectFromDict:userDict forKey:@"location_lng"];
    
    _numberOfPosts = [[CreateDataModelHelper validObjectFromDict:userDict forKey:@"number_of_posts"] integerValue];
    _followersCount = [[CreateDataModelHelper validObjectFromDict:userDict forKey:@"followersCount"] integerValue];
    _followingCount = [[CreateDataModelHelper validObjectFromDict:userDict forKey:@"followingCount"] integerValue];
    _isFollowedByCurrentUser = [[CreateDataModelHelper validObjectFromDict:userDict forKey:@"followed_by_current_user"] boolValue];
    
    //super properties
    self.mainImageUrl = [CreateDataModelHelper validObjectFromDict:userDict forKey:@"user_photo"];
    self.mainImageDownloaded = [STImageCacheController imageDownloadedForUrl:self.mainImageUrl];
    self.imageSize = CGSizeZero;

    
}

@end

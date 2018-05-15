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
#import "STListUser.h"

@implementation STUserProfile

+ (instancetype)userProfileWithDict:(NSDictionary *)userDict {
    STUserProfile * userProfile = [[STUserProfile alloc] init];
    [userProfile setupWithDict:userDict];
    return userProfile;
}

+ (instancetype)copyUserProfile:(STUserProfile *)profile{
    STUserProfile * userProfile = [[STUserProfile alloc] init];
    userProfile.uuid = profile.uuid;
    userProfile.appVersion = profile.appVersion;
    userProfile.bio = profile.bio;
    userProfile.birthday = profile.birthday;
    userProfile.isActive = profile.isActive;
    userProfile.wasNeverActive = profile.wasNeverActive;
    userProfile.lastActive = profile.lastActive;
    userProfile.firstname = profile.firstname;
    userProfile.fullName = profile.fullName;
    userProfile.lastName = profile.lastName;
    userProfile.homeLocation = profile.homeLocation;
    userProfile.latitude = profile.latitude;
    userProfile.longitude = profile.longitude;
    userProfile.numberOfPosts = profile.numberOfPosts;
    userProfile.followersCount = profile.followersCount;
    userProfile.followingCount = profile.followingCount;
    userProfile.isFollowedByCurrentUser = profile.isFollowedByCurrentUser;
    userProfile.profileShareUrl = profile.profileShareUrl;
    userProfile.username = profile.username;
    userProfile.mainImageUrl = profile.mainImageUrl;
    userProfile.mainImageDownloaded = profile.mainImageDownloaded;
    userProfile.imageSize = profile.imageSize;
    userProfile.gender = profile.gender;
    userProfile.profileGender = profile.profileGender;
    userProfile.isInfluencer = profile.isInfluencer;
    
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
    NSString *shortUrl = [CreateDataModelHelper validObjectFromDict:userDict forKey:@"short_url"];
    _profileShareUrl = [shortUrl stringByAddingHttp];
    _username = [CreateDataModelHelper validObjectFromDict:userDict forKey:@"username"];
    //super properties
    self.mainImageUrl = [[CreateDataModelHelper validObjectFromDict:userDict forKey:@"user_photo"] stringByReplacingHttpWithHttps];
    
    __weak STUserProfile *weakSelf = self;
    [STImageCacheController imageDownloadedForUrl:self.mainImageUrl completion:^(BOOL cached) {
        __strong STUserProfile *strongSelf = weakSelf;
        strongSelf.mainImageDownloaded = cached;
    }];
    self.imageSize = CGSizeZero;
    _gender = [CreateDataModelHelper validObjectFromDict:userDict forKey:@"gender"];
    if (!_gender) {
        _gender = @"other";
    }
    self.profileGender = [self genderFromString:_gender];
    self.isInfluencer = [[CreateDataModelHelper validObjectFromDict:userDict forKey:@"influencer"] boolValue];
}

- (STListUser *)listUserFromProfile{
    STListUser *lu = [STListUser new];
    //these params are the only on needed for now
    lu.followedByCurrentUser = @(self.isFollowedByCurrentUser);
    lu.uuid = self.uuid;
    lu.userName = self.fullName;
    lu.thumbnail = self.mainImageUrl;
    lu.gender = self.profileGender;
    
    return lu;
    
}

- (NSString *)genderImage{
    return [self genderImageNameForGender:self.profileGender];
}
- (NSString *)genderString{
    switch (self.profileGender) {
        case STProfileGenderMale:
            return NSLocalizedString(@"Male", nil);
            break;
        case STProfileGenderFemale:
            return NSLocalizedString(@"Female", nil);
            break;
        default:
            break;
    }
    
    return NSLocalizedString(@"Other", nil);
}
@end

//
//  STUserProfile.h
//  Status
//
//  Created by Silviu Burlacu on 07/06/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STBaseObj.h"

@class STListUser;

@interface STUserProfile : STBaseObj

@property (nonatomic, strong) NSString * fullName;
@property (nonatomic, strong) NSString * firstname;
@property (nonatomic, strong) NSString * lastName;

@property (nonatomic, strong) NSString * bio;
@property (nonatomic, strong) NSDate * birthday;
@property (nonatomic, strong) NSDate * lastActive;

@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, assign) BOOL wasNeverActive;

@property (nonatomic, assign) BOOL isFollowedByCurrentUser;
@property (nonatomic, assign) NSInteger followersCount;
@property (nonatomic, assign) NSInteger followingCount;

@property (nonatomic, strong) NSString * homeLocation;
@property (nonatomic, strong) NSString * latitude;
@property (nonatomic, strong) NSString * longitude;

@property (nonatomic, assign) NSInteger numberOfPosts;

@property (nonatomic, assign) STProfileGender profileGender;

+ (instancetype)userProfileWithDict:(NSDictionary *)userDict;

- (STListUser *)listUserFromProfile;

- (NSString *)genderImage;
@end

//
//  STFollowDataProcessor.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 01/06/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STFollowDataProcessor.h"
#import "STFacebookLoginController.h"
#import "STUserProfile.h"
#import "STUserProfilePool.h"
#import "STUsersPool.h"
#import "STListUser.h"

@interface STFollowDataProcessor()

@property(nonatomic, strong) NSSet *followedUsers;
@property(nonatomic, strong) NSSet *unfollowedUsers;


@end

@implementation STFollowDataProcessor
-(instancetype)initWithUsers:(NSArray *)users{
    self = [super init];
    if (self) {
        _followedUsers = [NSSet setWithArray:[users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"followedByCurrentUser == 1"]]];
        _unfollowedUsers = [NSSet setWithArray:[users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"followedByCurrentUser == 0"]]];

    }
    return self;
}

- (void)setUsers:(NSArray *)users {
    _followedUsers = [NSSet setWithArray:[users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"followedByCurrentUser == 1"]]];
    _unfollowedUsers = [NSSet setWithArray:[users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"followedByCurrentUser == 0"]]];
}

-(void)uploadDataToServer:(NSArray *)newData
           withCompletion:(STDataUploadCompletionBlock)completion{
    NSSet *suggestedUsersSet = [NSSet setWithArray:newData];
    NSMutableSet *checkedUsersToFollow = [NSMutableSet setWithSet:[suggestedUsersSet filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"followedByCurrentUser == 1"]]];
    [checkedUsersToFollow minusSet:_followedUsers];
    NSArray *unfollowUsersShouldFollow = [checkedUsersToFollow allObjects];
    __weak STFollowDataProcessor *weakSelf = self;
    [STDataAccessUtils followUsers:unfollowUsersShouldFollow
                    withCompletion:^(NSError *error) {
                        if (error == nil) {
                            NSArray *uuidArray = [unfollowUsersShouldFollow valueForKey:@"uuid"];
                            NSMutableArray <STSuggestedUser *> *allUsers = [[[CoreManager usersPool] getUsersForIds:uuidArray] mutableCopy];
                            [allUsers setValue:@(YES) forKey:@"followedByCurrentUser"];
                            [[CoreManager usersPool] addUsers:allUsers];
                        }
                        __strong STFollowDataProcessor *strongSelf = weakSelf;
                        NSLog(@"Error follow: %@", error.debugDescription);
                        NSMutableSet *uncheckedUsersToUnfollow = [NSMutableSet setWithSet:[suggestedUsersSet filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"followedByCurrentUser == 0"]]];
                        [uncheckedUsersToUnfollow minusSet:strongSelf.unfollowedUsers];
                        NSArray *followUsersShouldUnfollow = [uncheckedUsersToUnfollow allObjects];
                        
                        [STDataAccessUtils unfollowUsers:followUsersShouldUnfollow withCompletion:^(NSError *error) {
                            if (error == nil) {
                                NSArray *uuidArray = [followUsersShouldUnfollow valueForKey:@"uuid"];
                                NSMutableArray <STSuggestedUser *> *allUsers = [[[CoreManager usersPool] getUsersForIds:uuidArray] mutableCopy];
                                [allUsers setValue:@(NO) forKey:@"followedByCurrentUser"];
                                [[CoreManager usersPool] addUsers:allUsers];
                            }
                            NSLog(@"Error unfollow: %@", error.debugDescription);
                            
                            NSString *loggedInUserId = [[CoreManager loginService] currentUserUuid];
                            if (loggedInUserId) {
                                [STDataAccessUtils getUserProfileForUserId:loggedInUserId
                                                             andCompletion:^(NSArray *objects, NSError *error) {
                                                                 STUserProfile *userProfile = [objects firstObject];
                                                                 if (userProfile) {
                                                                     [[CoreManager profilePool] addProfiles:@[userProfile]];
                                                                     STSuggestedUser *lu = [[CoreManager usersPool] getUserWithId:userProfile.uuid];
                                                                     if (lu) {
                                                                         lu.followedByCurrentUser = @(userProfile.isFollowedByCurrentUser);
                                                                         lu.userName = userProfile.fullName;
                                                                         lu.thumbnail = userProfile.mainImageUrl;
                                                                         lu.gender = userProfile.profileGender;

                                                                         [[CoreManager usersPool] addUsers:@[lu]];
                                                                     }
                                                                 }
                                                                 
                                                                 if(completion) completion(error);
                                                             }];
                            }
                        }];
                    }];
}
@end

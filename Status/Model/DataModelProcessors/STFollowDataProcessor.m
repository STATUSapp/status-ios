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

@interface STFollowDataProcessor(){
    NSSet *_followedUsers;
    NSSet *_unfollowedUsers;
}

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
    [STDataAccessUtils followUsers:unfollowUsersShouldFollow
                    withCompletion:^(NSError *error) {
                        NSLog(@"Error follow: %@", error.debugDescription);
                        NSMutableSet *uncheckedUsersToUnfollow = [NSMutableSet setWithSet:[suggestedUsersSet filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"followedByCurrentUser == 0"]]];
                        [uncheckedUsersToUnfollow minusSet:_unfollowedUsers];
                        NSArray *followUsersShouldUnfollow = [uncheckedUsersToUnfollow allObjects];
                        
                        [STDataAccessUtils unfollowUsers:followUsersShouldUnfollow withCompletion:^(NSError *error) {
                            NSLog(@"Error unfollow: %@", error.debugDescription);
                            
                            NSString *loggedInUserId = [[CoreManager loginService] currentUserUuid];
                            if (loggedInUserId) {
                                [STDataAccessUtils getUserProfileForUserId:loggedInUserId
                                                             andCompletion:^(NSArray *objects, NSError *error) {
                                                                 STUserProfile *userProfile = [objects firstObject];
                                                                 if (userProfile) {
                                                                     [[CoreManager profilePool] addProfiles:@[userProfile]];
                                                                     
                                                                 }
                                                                 
                                                                 if(completion) completion(error);
                                                             }];
                            }
                        }];
                    }];
}
@end

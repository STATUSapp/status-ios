//
//  STLikesViewController.h
//  Status
//
//  Created by Cosmin Andrus on 3/4/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STWhiteNavBarViewController.h"

typedef NS_ENUM(NSUInteger, UsersListControllerType) {
    UsersListControllerTypeLikes,
    UsersListControllerTypeFollowing,
    UsersListControllerTypeFollowers
};

@interface STUsersListController : STWhiteNavBarViewController

@property (nonatomic, strong) NSString *postId;
@property (nonatomic, strong) NSString *userId;

@property (nonatomic, assign) UsersListControllerType controllerType;

+(instancetype)newControllerWithUserId:(NSString *)userID postID:(NSString *)postID andType:(UsersListControllerType)type;

@end

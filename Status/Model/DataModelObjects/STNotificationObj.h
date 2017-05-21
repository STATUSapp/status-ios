//
//  STNotificationObj.h
//  Status
//
//  Created by Andrus Cosmin on 21/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STBaseObj.h"

@class STListUser;

@interface STNotificationObj : STBaseObj

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *postPhotoUrl;
@property (nonatomic, strong) NSString *postId;
@property (nonatomic, assign) BOOL seen;
@property (nonatomic, assign) STNotificationType type;
@property (nonatomic, assign) BOOL followed;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userThumbnail;

+(STNotificationObj *)notificationObjFromDict:(NSDictionary *)dict;

- (STListUser *)listUserFromNotification;
@end

//
//  STNotificationObj.m
//  Status
//
//  Created by Andrus Cosmin on 21/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STNotificationObj.h"
#import "NSDate+Additions.h"
#import "STListUser.h"

@implementation STNotificationObj

+(STNotificationObj *)notificationObjFromDict:(NSDictionary *)dict{
    STNotificationObj *no = [STNotificationObj new];
    no.uuid = [[NSUUID UUID] UUIDString];
    no.infoDict = dict;
    no.appVersion = [CreateDataModelHelper validObjectFromDict:no.infoDict forKey:@"app_version"];
    NSString *dateString = [CreateDataModelHelper validObjectFromDict:no.infoDict forKey:@"date"];
    if (dateString) {
        no.date = [NSDate dateFromServerDateTime:dateString];
    }
    no.message = [CreateDataModelHelper validObjectFromDict:no.infoDict forKey:@"message"];
    no.postId = [CreateDataModelHelper validObjectFromDict:no.infoDict forKey:@"post_id"];
    no.postPhotoUrl = [[CreateDataModelHelper validObjectFromDict:no.infoDict forKey:@"post_photo_link"] stringByReplacingOccurrencesOfString:@"_th" withString:@""];
    no.seen = [no.infoDict[@"seen"] boolValue];
    no.type = [no.infoDict[@"type"] integerValue];
    no.userId = [CreateDataModelHelper validStringIdentifierFromValue:no.infoDict[@"user_id"]];
    no.userName = [CreateDataModelHelper validObjectFromDict:no.infoDict forKey:@"user_name"];
    no.userThumbnail = [CreateDataModelHelper validObjectFromDict:no.infoDict forKey:@"user_photo_link"];
    no.followed = [no.infoDict[@"followed_by_current_user"] boolValue];
    return no;
    
}

- (STListUser *)listUserFromNotification{
    STListUser *lu = [STListUser new];
    //these params are the only on needed for now
    lu.followedByCurrentUser = @(self.followed);
    lu.uuid = self.userId;
    lu.userName = self.userName;
    lu.thumbnail = self.userThumbnail;
    
    return lu;
    
}

@end

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
#import "STTopBase.h"
#import "STPostsPool.h"

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
    no.userGender = [no genderFromString:no.infoDict[@"user_gender"]];
    
    return no;
    
}

+(NSArray<STNotificationObj *> *)topMockNotifications{
    NSArray *postWithTops = [[CoreManager postsPool] randomPostsForAllTops];
    STPost *postDaily = nil;
    STPost *postWeekly = nil;
    STPost *postMonthly = nil;

    for (STPost *post in postWithTops) {
        NSInteger index = [postWithTops indexOfObject:post];
        if (index == 0) {
            postDaily = post;
        }
        if (index == 1) {
            postWeekly = post;
        }
        if (index == 2) {
            postMonthly = post;
        }
    }
    
    NSMutableArray *result = [NSMutableArray new];

    if (postDaily) {
        STNotificationObj *topTodayMock = [STNotificationObj new];
        topTodayMock.uuid = [[NSUUID UUID] UUIDString];
        topTodayMock.appVersion = @"2.9";
        topTodayMock.date = [NSDate date];
        topTodayMock.message = @"Top Best Dressed people today";
        topTodayMock.seen = NO;
        topTodayMock.type = STNotificationTypeTop;
        topTodayMock.userName = @"Top Best Dressed";
        topTodayMock.topId = postDaily.dailyTop.topId;
        
        STNotificationObj *yourDailyTopMock = [STNotificationObj new];
        yourDailyTopMock.uuid = [[NSUUID UUID] UUIDString];
        yourDailyTopMock.appVersion = @"2.9";
        yourDailyTopMock.date = [NSDate date];
        yourDailyTopMock.top = postDaily.dailyTop;
        yourDailyTopMock.message = [NSString stringWithFormat:@"Big congrats! You are number %@ in Top Best Dressed people today", yourDailyTopMock.top.rank];
        yourDailyTopMock.seen = NO;
        yourDailyTopMock.type = STNotificationTypeShareTop;
        yourDailyTopMock.userName = @"Top Best Dressed";
        yourDailyTopMock.postPhotoUrl = postDaily.mainImageUrl;
        yourDailyTopMock.postId = postDaily.uuid;

        [result addObject:topTodayMock];
        [result addObject:yourDailyTopMock];
    }
    
    if (postWeekly) {
        STNotificationObj *topWeekMock = [STNotificationObj new];
        topWeekMock.uuid = [[NSUUID UUID] UUIDString];
        topWeekMock.appVersion = @"2.9";
        topWeekMock.date = [NSDate date];
        topWeekMock.message = @"Top Best Dressed people weekly";
        topWeekMock.seen = NO;
        topWeekMock.type = STNotificationTypeTop;
        topWeekMock.userName = @"Top Best Dressed";
        topWeekMock.topId = postWeekly.weeklyTop.topId;
        
        STNotificationObj *yourWeeklyTopMock = [STNotificationObj new];
        yourWeeklyTopMock.uuid = [[NSUUID UUID] UUIDString];
        yourWeeklyTopMock.appVersion = @"2.9";
        yourWeeklyTopMock.date = [NSDate date];
        yourWeeklyTopMock.top = postWeekly.weeklyTop;
        yourWeeklyTopMock.message = [NSString stringWithFormat:@"Big congrats! You are number %@ in Top Best Dressed people weekly", yourWeeklyTopMock.top.rank];
        yourWeeklyTopMock.seen = NO;
        yourWeeklyTopMock.type = STNotificationTypeShareTop;
        yourWeeklyTopMock.userName = @"Top Best Dressed";
        yourWeeklyTopMock.postPhotoUrl = postWeekly.mainImageUrl;
        yourWeeklyTopMock.postId = postWeekly.uuid;

        [result addObject:topWeekMock];
        [result addObject:yourWeeklyTopMock];

    }

    if (postMonthly) {
        STNotificationObj *topMonthlyMock = [STNotificationObj new];
        topMonthlyMock.uuid = [[NSUUID UUID] UUIDString];
        topMonthlyMock.appVersion = @"2.9";
        topMonthlyMock.date = [NSDate date];
        topMonthlyMock.message = @"Top Best Dressed people monthly";
        topMonthlyMock.seen = NO;
        topMonthlyMock.type = STNotificationTypeTop;
        topMonthlyMock.userName = @"Top Best Dressed";
        topMonthlyMock.topId = postMonthly.monthlyTop.topId;
        
        STNotificationObj *yourMonthlyTopMock = [STNotificationObj new];
        yourMonthlyTopMock.uuid = [[NSUUID UUID] UUIDString];
        yourMonthlyTopMock.appVersion = @"2.9";
        yourMonthlyTopMock.date = [NSDate date];
        yourMonthlyTopMock.top = postMonthly.monthlyTop;
        yourMonthlyTopMock.message = [NSString stringWithFormat:@"Big congrats! You are number %@ in Top Best Dressed people monthly", yourMonthlyTopMock.top.rank];
        yourMonthlyTopMock.seen = NO;
        yourMonthlyTopMock.type = STNotificationTypeShareTop;
        yourMonthlyTopMock.userName = @"Top Best Dressed";
        yourMonthlyTopMock.postPhotoUrl = postMonthly.mainImageUrl;
        yourMonthlyTopMock.postId = postMonthly.uuid;

        [result addObject:topMonthlyMock];
        [result addObject:yourMonthlyTopMock];

    }
    
    


    return result;
}

- (STListUser *)listUserFromNotification{
    STListUser *lu = [STListUser new];
    //these params are the only on needed for now
    lu.followedByCurrentUser = @(self.followed);
    lu.uuid = self.userId;
    lu.userName = self.userName;
    lu.thumbnail = self.userThumbnail;
    lu.gender = self.userGender;
    
    return lu;
    
}

+ (NSArray<NSNumber *> *)smartNotifications{
    return @[
             @(STNotificationTypePhotosWaiting),
             @(STNotificationTypeNewUserJoinsStatus),
             @(STNotificationTypeGuaranteedViewsForNextPhoto),
             @(STNotificationType5DaysUploadNewPhoto)
             ];
}

+ (NSArray<NSNumber *> *)topNotifications{
    return @[
             @(STNotificationTypeTop),
             @(STNotificationTypeShareTop)
             ];
}
@end

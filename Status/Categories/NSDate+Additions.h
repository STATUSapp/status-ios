//
//  NSDate+Additions.h
//  Status
//
//  Created by Silviu Burlacu on 23/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Additions)

+ (NSDate *) dateFromServerDateTime:(NSString *) serverDate;
+ (NSDate *)dateFromServerDate:(NSString *)serverDate;
+ (NSString *)notificationTimeIntervalSinceDate: (NSDate *)dateOfNotification;
+ (NSString *)yearsFromDate:(NSDate *)referenceDate;
+ (NSString *)birthdayStringFromFacebookBirthday:(NSString *)birthday;
+ (NSString *)statusForLastTimeSeen:(NSDate *)lastSeenDate;
+ (NSString *)timeStringForLastMessageDate:(NSDate *)messageDate;
+ (STUserStatus)statusTypeForLastTimeSeen:(NSDate *)lastSeenDate;

@end

//
//  NSDate+Additions.m
//  Status
//
//  Created by Silviu Burlacu on 23/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "NSDate+Additions.h"

@implementation NSDate (Additions)

+ (NSDate *) dateFromServerDateTime:(NSString *) serverDate{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    NSDate *resultDate = [dateFormatter dateFromString:serverDate];
    return resultDate;
}

+ (NSDate *)dateFromServerDate:(NSString *)serverDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    NSDate *resultDate = [dateFormatter dateFromString:serverDate];
    return resultDate;
}


+ (NSString *)notificationTimeIntervalSinceDate: (NSDate *)dateOfNotification{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:dateOfNotification];
    
    if (0 <= timeInterval && timeInterval <= 60) {
        return @"JUST NOW";
    }
    int mins = timeInterval / 60;
    if (mins <= 60) {
        return [NSString stringWithFormat:@" %d MIN%@", mins, (mins==1)?@"":@"S"];
    }
    int hours = timeInterval / 3600;
    if (hours <= 24) {
        return [NSString stringWithFormat:@" %d HR%@", hours, (hours==1)?@"":@"S"];
    }
    
    if (timeInterval / 3600 <= 48) {
        return @"YESTERDAY";
    }
    
    return [NSString stringWithFormat:@"%d DAYS", (int)(timeInterval / 86400)];
}

+ (NSString *)yearsFromDate:(NSDate *)referenceDate {
    if (referenceDate == nil) {
        return nil;
    }
    
    NSDate *today = [NSDate date];
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    // pass as many or as little units as you like here, separated by pipes
    NSUInteger units = NSYearCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
    
    NSDateComponents *components = [gregorianCalendar components:units fromDate:referenceDate toDate:today options:0];
    
    NSInteger years = [components year];
//    NSInteger months = [components month];
//    NSInteger days = [components day];
    
    return [NSString stringWithFormat:@"%li", (long)years];
}

+(NSString *)birthdayStringFromFacebookBirthday:(NSString *)birthday{
    if (birthday==nil||[birthday isKindOfClass:[NSNull class]]) {
        return nil;
    }
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"MM/dd/yyyy";
    NSDate *birthdayDate = [df dateFromString:birthday];
    
    df.dateFormat = @"yyyy-MM-dd";
    
    return [df stringFromDate:birthdayDate];
    
}

+ (NSString *)statusForLastTimeSeen:(NSDate *)lastSeenDate {
    NSTimeInterval timeInterval =  [[NSDate date] timeIntervalSinceDate:lastSeenDate];
    
    if (timeInterval < 0) {
        timeInterval = - timeInterval;
    }
    
    if (0 <= timeInterval && timeInterval <= 60) {
        return @"Active";
    }
    int mins = timeInterval / 60;
    if (mins <= 60) {
        return [NSString stringWithFormat:@"Active %d minute%@ ago", mins, (mins==1)?@"":@"s"];
    }
    int hours = timeInterval / 3600;
    if (hours <= 24) {
        return [NSString stringWithFormat:@"Active %d hour%@ ago", hours, (hours==1)?@"":@"s"];
    }
    
    if (timeInterval / 3600 <= 48) {
        return @"Active yesterday";
    }
    
    if (timeInterval <= 86400 * 7) {
        return [NSString stringWithFormat:@"Active %d days ago", (int)(timeInterval / 86400)];
    }
    
    
    int weeks = timeInterval / ( 86400 * 7 );
    if (timeInterval <= (4 * 86400 * 7)) {
        return [NSString stringWithFormat:@"Active %d week%@ ago", weeks, (weeks == 1) ? @"" : @"s"];
    }
    
    int months = timeInterval / (86400 * 30);
    if (timeInterval < 12 * 86400 * 30) {
        return [NSString stringWithFormat:@"Active %d month%@ ago", months, (months == 1) ? @"" : @"s"];
    }
    
    int years = [[NSDate yearsFromDate:lastSeenDate] intValue];
    return [NSString stringWithFormat:@"Active %d year%@ ago", years, (years == 1) ? @"" : @"s"];
}

+ (NSString *)timeStringForLastMessageDate:(NSDate *)messageDate{
    NSTimeInterval timeInterval =  [[NSDate date] timeIntervalSinceDate:messageDate];
    NSString *returnTimeString=@"";
    if (timeInterval<3600) {
        returnTimeString = [NSString stringWithFormat:@"%ldm",(long)timeInterval/60 + 1];
    }
    else if (timeInterval<3600*24){
        returnTimeString = [NSString stringWithFormat:@"%ldh",(long)timeInterval/3600];
    }
    else if (timeInterval<3600*24*7){
        returnTimeString = [NSString stringWithFormat:@"%ldd",(long)timeInterval/(3600*24)];
    }
    else if (timeInterval < 3600*24*7*52){
        returnTimeString = [NSString stringWithFormat:@"%ldw",(long)timeInterval/(3600*24*7)+1];
    }
    else
        returnTimeString = [NSString stringWithFormat:@"%ldy",(long)timeInterval/(3600*24*7*52)];
    
    return returnTimeString;
}

+ (STUserStatus)statusTypeForLastTimeSeen:(NSDate *)lastSeenDate {
    NSTimeInterval timeInterval =  [[NSDate date] timeIntervalSinceDate:lastSeenDate];
    
    if (timeInterval <= 3600 ) {
        return STUserStatusActive;
    }
    
    if (timeInterval <= 86400 * 30) {
        return STUserStatusAway;
    }
    
    return STUserStatusOffline;
}

@end

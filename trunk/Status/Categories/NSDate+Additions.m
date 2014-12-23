//
//  NSDate+Additions.m
//  Status
//
//  Created by Silviu Burlacu on 23/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "NSDate+Additions.h"

@implementation NSDate (Additions)

+ (NSDate *) dateFromServerDate:(NSString *) serverDate{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
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
    NSDate *today = [NSDate date];
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    // pass as many or as little units as you like here, separated by pipes
    NSUInteger units = NSYearCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
    
    NSDateComponents *components = [gregorianCalendar components:units fromDate:referenceDate toDate:today options:0];
    
    NSInteger years = [components year];
//    NSInteger months = [components month];
//    NSInteger days = [components day];
    
    return [NSString stringWithFormat:@"%li", years];
}

@end

//
//  STInviteController.m
//  Status
//
//  Created by Cosmin Andrus on 6/30/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STInviteController.h"

static long const kWeekSeconds = 3600*24*7;

@implementation STInviteController

+(STInviteController *) sharedInstance{
    static STInviteController *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

-(NSString *)keyForNumber:(NSNumber *)number{
    return [NSString stringWithFormat:@"inviteNumber%d", number.integerValue];
}

-(void)setCurrentDateForInviteNumber:(NSNumber *)number{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:[NSDate date] forKey:[self keyForNumber:number]];
    [ud synchronize];
}

-(BOOL)validInviteNumber:(NSNumber *)number{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

    return [ud objectForKey:[self keyForNumber:number]]!=nil;
}

-(BOOL)shouldInviteBeAvailable{
    NSDate *currentDate = [NSDate date];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDate *latestInviteDate = [ud objectForKey:[self keyForNumber:@(0)]];
    NSDate *otherDate1 = [ud objectForKey:[self keyForNumber:@(1)]];
    NSDate *otherDate2 = [ud objectForKey:[self keyForNumber:@(2)]];
    
    if (latestInviteDate == nil || otherDate1 ==nil || otherDate2 == nil) {//one of the dates is nil
        return YES;
    }
    
    NSMutableArray *otherDates = [NSMutableArray new];
    if (otherDate1!=nil) {
        [otherDates addObject:otherDate1];
    }
    if (otherDate2!=nil) {
        [otherDates addObject:otherDate2];
    }
    
    for (NSDate *date in otherDates) {
        if ([latestInviteDate compare:date] == NSOrderedAscending) {
            latestInviteDate = date;
        }
    }
    
    NSDate *oneWeekLaterDate = [latestInviteDate dateByAddingTimeInterval:kWeekSeconds];
    
    if ([oneWeekLaterDate compare:currentDate] == NSOrderedAscending) {
        return YES;
    }
    
    return NO;
    
    
}

@end

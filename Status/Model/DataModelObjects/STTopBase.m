//
//  STTopBase.m
//  Status
//
//  Created by Cosmin Andrus on 08/07/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STTopBase.h"
#import "NSDate+Additions.h"

@interface STTopBase ()

@property (nonatomic, strong, readwrite) NSString *topId;
@property (nonatomic, strong, readwrite) NSNumber *rank;
@property (nonatomic, strong, readwrite) NSDate *startDate;
@property (nonatomic, strong, readwrite) NSDate *endDate;
@property (nonatomic, assign, readwrite) STTopType type;
@property (nonatomic, strong, readwrite) NSDictionary *userInfo;

@end

@implementation STTopBase

-(instancetype)initWithInfo:(NSDictionary *)userInfo{
    self = [super init];
    if (self) {
        _userInfo = userInfo;
        _topId = userInfo[@"top_id"];
        _rank = userInfo[@"rank"];
        _startDate = [NSDate dateFromServerDateTime:userInfo[@"top_start_date"]];
        _endDate = [NSDate dateFromServerDateTime:userInfo[@"top_end_date"]];
    }
    return self;
}

- (NSComparisonResult)compare:(STTopBase *)otherTop{
    return [self.rank compare:otherTop.rank];
}

+ (STTopBase *)dailyTopWithInfo:(NSDictionary *)dailyInfo{
    if (!dailyInfo) {
        return nil;
    }
    STTopBase *topObj = [[STTopBase alloc] initWithInfo:dailyInfo];
    topObj.type = STTopTypeDaily;
    
    return topObj;
}
+ (STTopBase *)weeklyTopWithInfo:(NSDictionary *)weeklyInfo{
    if (!weeklyInfo) {
        return nil;
    }
    STTopBase *topObj = [[STTopBase alloc] initWithInfo:weeklyInfo];
    topObj.type = STTopTypeWeekly;
    
    return topObj;

}
+ (STTopBase *)monthlyTopWithInfo:(NSDictionary *)monthlyInfo{
    if (!monthlyInfo) {
        return nil;
    }
    STTopBase *topObj = [[STTopBase alloc] initWithInfo:monthlyInfo];
    topObj.type = STTopTypeMonthly;
    
    return topObj;

}

- (UIColor *)topColor{
    UIColor *result = [UIColor clearColor];
    switch (self.type) {
        case STTopTypeDaily:{
            result = [UIColor blackColor];
        }
            break;
        case STTopTypeWeekly:{
            result = [UIColor colorWithRed:203.f/255.f
                                     green:30.f/255.f
                                      blue:64.f/255.f
                                     alpha:1.f];
        }
            break;
        case STTopTypeMonthly:{
            result = [UIColor colorWithRed:238.f/255.f
                                     green:138.f/255.f
                                      blue:1.f/255.f
                                     alpha:1.f];
        }
            break;
    }
    return result;
}

- (NSString *)rankString{
    return [NSString stringWithFormat:@"#%ld", (long)self.rank.integerValue];
}

- (NSAttributedString *)topDetails{
    NSString *rankNumberString = [self rankNumberString];
    NSString *topTypeAndDate = [self topTypeAndDate];
    
    NSString *fullDetails = [NSString stringWithFormat:@"%@ %@", rankNumberString, topTypeAndDate];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:fullDetails attributes:@{
                                                                                                                                                                             NSFontAttributeName: [UIFont fontWithName:@"ProximaNova-Regular" size: 14.0f],
                                                                                                                                                                             NSForegroundColorAttributeName: [UIColor colorWithWhite:0.0f alpha:1.0f],
                                                                                                                                                                             NSKernAttributeName: @(0.0)
                                                                                                                                                                             }];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ProximaNova-Semibold" size: 14.0f] range:[fullDetails rangeOfString:rankNumberString]];
    
    return attributedString;
}

- (NSString *)rankNumberString{
    NSString *result = [NSString stringWithFormat:@"No. %ld in Top Best Dressed", (long)self.rank.integerValue];
    return result;
}

- (NSString *)topTypeAndDate{
    NSString *topType = nil;
    NSString *topDate = nil;
    
    NSDateFormatter *dailyDateFormatter = [NSDateFormatter new];
    dailyDateFormatter.dateFormat = @"dd.MM.yyyy";
    
    NSDateFormatter *weeklyStartDateFormatter = [NSDateFormatter new];
    weeklyStartDateFormatter.dateFormat = @"dd";
    
    NSDateFormatter *weeklyEndDateFormatter = [NSDateFormatter new];
    weeklyEndDateFormatter.dateFormat = @"dd.MM.yyyy";
    
    NSDateFormatter *monthlyDateFormatter = [NSDateFormatter new];
    monthlyDateFormatter.dateFormat = @"MM.yyyy";
    
    switch (self.type) {
        case STTopTypeDaily:{
            topType  = @"daily";
            topDate = [dailyDateFormatter stringFromDate:self.startDate];
        }
            break;
        case STTopTypeWeekly:{
            topType  = @"weekly";
            topDate = [NSString stringWithFormat:@"%@/%@", [weeklyStartDateFormatter stringFromDate:self.startDate], [weeklyEndDateFormatter stringFromDate:self.endDate]];
        }
            break;
        case STTopTypeMonthly:{
            topType  = @"monthly";
            topDate = [monthlyDateFormatter stringFromDate:self.startDate];
        }
            break;
    }
    
    NSString *result = [NSString stringWithFormat:@"people %@. (%@)", topType, topDate];
    return result;
}

+ (STTopBase *)mockDailyTop{
    NSInteger mockRank = [STTopBase mockRank];
    if (mockRank%2 == 0) {
        return nil;
    }
    STTopBase *top = [STTopBase new];
    top.type = STTopTypeDaily;
    top.rank = @(mockRank);
    top.startDate = [NSDate date];
    return top;
}
+ (STTopBase *)mockWeeklyTop{
    NSInteger mockRank = [STTopBase mockRank];
    if (mockRank%2 == 0) {
        return nil;
    }
    STTopBase *top = [STTopBase new];
    top.type = STTopTypeWeekly;
    top.rank = @(mockRank);
    top.startDate = [[NSDate date] dateByAddingTimeInterval:(-1) * 3600 * 24 * 7];
    top.endDate = [NSDate date];
    return top;
}
+ (STTopBase *)mockMonthlyTop{
    NSInteger mockRank = [STTopBase mockRank];
    if (mockRank%2 == 0) {
        return nil;
    }
    STTopBase *top = [STTopBase new];
    top.type = STTopTypeMonthly;
    top.rank = @(mockRank);
    top.startDate = [NSDate date];
    return top;
}

+ (NSInteger)mockRank{
    uint32_t random = arc4random_uniform(500); 
    return (NSInteger)(random);
}
@end

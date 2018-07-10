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

-(NSComparisonResult)compare:(STTopBase *)otherTop{
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

@end

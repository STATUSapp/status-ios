//
//  STTopBase.h
//  Status
//
//  Created by Cosmin Andrus on 08/07/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, STTopType) {
    STTopTypeUndefined = 0,
    STTopTypeDaily,
    STTopTypeWeekly,
    STTopTypeMonthly,
};
@interface STTopBase : NSObject

@property (nonatomic, strong, readonly) NSString *topId;
@property (nonatomic, strong, readonly) NSNumber *rank;
@property (nonatomic, strong, readonly) NSDate *startDate;
@property (nonatomic, strong, readonly) NSDate *endDate;
@property (nonatomic, assign, readonly) STTopType type;
@property (nonatomic, strong, readonly) NSNumber *likesCount;
@property (nonatomic, strong, readonly) NSDictionary *userInfo;

- (NSComparisonResult)compare:(STTopBase *)otherTop;
-( UIColor *)topColor;
- (NSString *)rankString;
- (NSAttributedString *)topDetails;
- (NSString *)topTypeString;

+ (STTopBase *)dailyTopWithInfo:(NSDictionary *)dailyInfo;
+ (STTopBase *)weeklyTopWithInfo:(NSDictionary *)weeklyInfo;
+ (STTopBase *)monthlyTopWithInfo:(NSDictionary *)monthlyInfo;
+ (STTopBase *)topWithInfo:(NSDictionary *)info;
+ (UIColor *)topOneBorderColor;
+ (CGFloat)topOneBorderWidth;
+ (UIColor *)topTwoBorderColor;
+ (CGFloat)topTwoBorderWidth;
+ (UIColor *)topThreeBorderColor;
+ (CGFloat)topThreeBorderWidth;

+ (STTopBase *)mockDailyTop;
+ (STTopBase *)mockWeeklyTop;
+ (STTopBase *)mockMonthlyTop;

@end

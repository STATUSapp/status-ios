//
//  STExploreFilters.h
//  Status
//
//  Created by Cosmin Andrus on 06/09/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, STExploreFiltersType) {
    STExploreFiltersTypePopular = 0,
    STExploreFiltersTypeRecent
};

typedef NS_ENUM(NSUInteger, STExploreFiltersTimeframe) {
    STExploreFiltersTimeframeDaily = 0,
    STExploreFiltersTimeframeWeekly,
    STExploreFiltersTimeframeMonthly,
    STExploreFiltersTimeframeAllTime
};

typedef NS_ENUM(NSUInteger, STExploreFiltersGender) {
    STExploreFiltersGenderWomen,
    STExploreFiltersGenderMen,
    STExploreFiltersGenderBoth,
};

@class STExploreFilters;

@protocol STExploreFiltersProtocol <NSObject>

-(STExploreFiltersTimeframe)defaultTimeframeOptionWithSender:(STExploreFilters *)sender;
-(STExploreFiltersGender)defaultGenderOptionWithSender:(STExploreFilters *)sender;
-(void)filtersChangedInTimeFrame:(STExploreFiltersTimeframe)timeframe
                       andGender:(STExploreFiltersGender)gender
                       forSender:(STExploreFilters *)sender;
@end
@interface STExploreFilters : UIView

+ (STExploreFilters *)exploreFiltersWithDelegate:(id<STExploreFiltersProtocol>)delegate
                                         andType:(STExploreFiltersType)type;

@end

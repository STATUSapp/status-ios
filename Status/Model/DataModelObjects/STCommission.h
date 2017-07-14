//
//  STCommissions.h
//  Status
//
//  Created by Cosmin Andrus on 05/07/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STBaseObj.h"
typedef NS_ENUM(NSUInteger, STCommissionState) {
    STCommissionStateNone = 0,
    STCommissionStateWithdrawn,
    STCommissionStatePaid,
};
@interface STCommission : STBaseObj

@property (nonatomic, strong) NSString *productName;
@property (nonatomic, strong) NSString *productBrandName;
@property (nonatomic, strong) NSDate *commissionDate;
@property (nonatomic, strong) NSNumber *commissionAmount;//US dollars
@property (nonatomic, assign) STCommissionState commissionState;

+ (STCommission *)commissionsObjWithDict:(NSDictionary *)dict;

@end

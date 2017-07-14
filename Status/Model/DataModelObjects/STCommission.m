//
//  STCommissions.m
//  Status
//
//  Created by Cosmin Andrus on 05/07/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STCommission.h"
#import "NSDate+Additions.h"

@implementation STCommission

+ (STCommission *)commissionsObjWithDict:(NSDictionary *)dict{
    STCommission *commission = [STCommission new];
    NSLog(@"Dict: %@", dict);

    //TODO: make this consistent with the server
    commission.uuid = dict[@"id"];
    commission.mainImageUrl = dict[@"product_image"];
    commission.mainImageDownloaded = NO;
    commission.productName = dict[@"product_name"];
    commission.productBrandName = dict[@"product_brand_name"];
    commission.commissionDate = [NSDate dateFromServerDate:dict[@"commission_date"]];
    commission.commissionAmount = dict[@"commission_ammount"];
    commission.commissionState = [self commssionStateFromString:dict[@"commission_state"]];
    return commission;
}

+ (STCommissionState)commssionStateFromString:(NSString *)stateString{
    STCommissionState state = STCommissionStateNone;
    if ([stateString isKindOfClass:[NSString class]]) {
        if ([stateString isEqualToString:@"withdrawn"]) {
            state = STCommissionStateWithdrawn;
        }
        if ([stateString isEqualToString:@"paid"]) {
            state = STCommissionStatePaid;
        }
    }
    
    return state;
}
@end

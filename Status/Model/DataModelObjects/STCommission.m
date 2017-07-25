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
    commission.mainImageUrl = dict[@"product"][@"image_url"];
    commission.mainImageDownloaded = NO;
    commission.productName = dict[@"product"][@"name"];
    commission.productBrandName = [NSString stringWithFormat:@"%@",dict[@"product"][@"brand_name"]];
    commission.commissionDate = [NSDate dateFromServerDateTime:dict[@"date_add"]];
    commission.commissionAmount = @([dict[@"amount"] doubleValue]);
    commission.commissionState = [self commssionStateFromString:dict[@"withdrawn_status"]];
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

//
//  STCommissions.m
//  Status
//
//  Created by Cosmin Andrus on 05/07/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STCommission.h"

@implementation STCommission

+ (STCommission *)commissionsObjWithDict:(NSDictionary *)dict{
    STCommission *commissions = [STCommission new];
    NSLog(@"Dict: %@", dict);
//TODO: add configuration here
    return commissions;
}

@end

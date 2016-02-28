//
//  CreateDataModelHelper.m
//  Status
//
//  Created by Silviu Burlacu on 07/06/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "CreateDataModelHelper.h"

@implementation CreateDataModelHelper

+ (id)validObjectFromDict:(NSDictionary *)dict forKey:(NSString *)key {
    if ([dict[key] isKindOfClass:[NSNull class]]) {
        return nil;
    } else {
        return dict[key];
    }
}

+ (id)validStringIdentifierFromValue:(id)value {
    NSString *stringValue = nil;
    if ([value isKindOfClass:[NSNumber class]]) {
        stringValue = [value stringValue];
    }
    else if ([value isKindOfClass:[NSString class]])
        stringValue = value;
    return stringValue;

}


@end

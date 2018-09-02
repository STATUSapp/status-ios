//
//  NSDictionary+Additions.m
//  Status
//
//  Created by Cosmin Andrus on 31/08/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "NSDictionary+Additions.h"

@implementation NSDictionary (Additions)

-(void)logJsonString{
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Json string = \n%@", jsonString);
}

@end

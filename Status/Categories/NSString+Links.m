//
//  NSString+Links.m
//  Status
//
//  Created by Cosmin Andrus on 31/05/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "NSString+Links.h"

@implementation NSString (Links)

-(NSString *)stringByReplacingHttpWithHttps{
    NSRange httpRange = [self rangeOfString:@"http"];
    if (httpRange.location != NSNotFound) {
        NSRange httpsRange = [self rangeOfString:@"https"];
        if (httpsRange.location == NSNotFound) {
            return [self stringByReplacingOccurrencesOfString:@"http" withString:@"https"];
        }
    }
    
    return self;
}

@end

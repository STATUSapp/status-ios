//
//  NSString+VersionComparison.m
//  Status
//
//  Created by Andrus Cosmin on 12/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "NSString+VersionComparison.h"

@implementation NSString (VersionComparison)

-(NSComparisonResult)compareWithVersion:(NSString *)otherVersion{
    NSMutableArray *currentVersionArray = [NSMutableArray arrayWithArray:[self componentsSeparatedByString:@"."]];
    NSMutableArray *otherVersionArray = [NSMutableArray arrayWithArray:[otherVersion componentsSeparatedByString:@"."]];
    
    NSInteger maxSubVersionNumbers = MAX([currentVersionArray count], [otherVersionArray count]);
    
    for (int i =0; i < maxSubVersionNumbers; i++) {
        if ([currentVersionArray count] <= i) {
            [currentVersionArray addObject:@"0"];
        }
        if ([otherVersionArray count] <= i) {
            [otherVersionArray addObject:@"0"];
        }

    }
    NSComparisonResult result = NSOrderedSame;
    
    for (int i=0; i< MIN([currentVersionArray count], [otherVersionArray count]); i++) {
        NSInteger firstNr = [currentVersionArray[i] integerValue];
        NSInteger secondNr = [otherVersionArray[i] integerValue];
        if (firstNr > secondNr) {
            result = NSOrderedDescending;
            break;
        }
        else if (firstNr < secondNr){
            result = NSOrderedAscending;
            break;
        }
    }
    return result;
}

-(BOOL)isGreaterThanVersion:(NSString *)version{
    NSComparisonResult result = [self compareWithVersion:version];
    return result == NSOrderedDescending;
}
-(BOOL)isGreaterThanEqualWithVersion:(NSString *)version{
    NSComparisonResult result = [self compareWithVersion:version];
    return (result == NSOrderedDescending || result == NSOrderedSame);
}
-(BOOL)isSmallerThanVersion:(NSString *)version{
    NSComparisonResult result = [self compareWithVersion:version];
    return result == NSOrderedAscending;
}
-(BOOL)isSmallerThanEqualWithVersion:(NSString *)version{
    NSComparisonResult result = [self compareWithVersion:version];
    return (result == NSOrderedAscending || NSOrderedSame);
}


@end

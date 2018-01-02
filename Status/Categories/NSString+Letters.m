//
//  NSString+Letters.m
//  Status
//
//  Created by Cosmin Andrus on 31/12/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "NSString+Letters.h"

@implementation NSString (Letters)

+(NSArray *)allCapsLetters{
    NSArray *lettersArray = @[@"A", @"B", @"C", @"D", @"E",
                              @"F", @"G", @"H", @"I", @"J",
                              @"K", @"L", @"M", @"N", @"O",
                              @"P", @"Q", @"R", @"S", @"T",
                              @"U", @"V", @"W", @"X", @"Y",
                              @"Z"];
    return lettersArray;

}

@end

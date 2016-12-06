//
//  NSString+HashTags.m
//  Status
//
//  Created by Cosmin Andrus on 15/11/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "NSString+HashTags.h"

@implementation NSString (HashTags)
-(NSArray *)hashTags{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)" options:0 error:&error];
    NSArray *matches = [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    NSMutableArray *hashTags = [NSMutableArray new];
    
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:1];
        wordRange.location = wordRange.location-1;
        wordRange.length = wordRange.length + 1;
        NSString* word = [self substringWithRange:wordRange];
        [hashTags addObject:word];
        NSLog(@"Found tag %@", word);
    }
    return hashTags;
}
@end

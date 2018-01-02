//
//  Message+CoreDataClass.m
//  Status
//
//  Created by Cosmin Andrus on 31/12/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//
//

#import "Message+CoreDataClass.h"

@implementation Message

-(NSString *)sectionDate{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd MMM yyyy";
    
    NSString *dateString = [formatter stringFromDate:self.date];
    
    return dateString;
}
@end

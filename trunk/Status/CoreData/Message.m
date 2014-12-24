//
//  Message.m
//  Status
//
//  Created by Cosmin Andrus on 09/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "Message.h"
#import "STChatController.h"

@implementation Message

@dynamic date;
@dynamic message;
@dynamic received;
@dynamic roomID;
@dynamic seen;
@dynamic userId;
@dynamic uuid;
@dynamic sectionDate;

-(NSString *)sectionDate{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterLongStyle];
    
//    NSString *dateString = [formatter stringFromDate:self.date];
//    
//    return dateString;
    
    float minInterval = -MAXFLOAT;
    
    for (int i=0;i<[STChatController sharedInstance].roomSections.count;i++) {
        if ([self.date timeIntervalSinceDate:[STChatController sharedInstance].roomSections[i]] < minInterval) {
            minInterval = minInterval;
        }
    }

    //TODO: test this when chat on
    NSDate *sectionDate = [self.date dateByAddingTimeInterval:minInterval];
    return [formatter stringFromDate:sectionDate];
    
}
@end

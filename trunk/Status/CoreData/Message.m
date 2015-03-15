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
    formatter.dateFormat = @"dd MMM yyyy";
    
    NSString *dateString = [formatter stringFromDate:self.date];
    
    return dateString;
}
@end

//
//  Message+CoreDataProperties.m
//  Status
//
//  Created by Cosmin Andrus on 31/12/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//
//

#import "Message+CoreDataProperties.h"

@implementation Message (CoreDataProperties)

+ (NSFetchRequest<Message *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Message"];
}

@dynamic date;
@dynamic message;
@dynamic received;
@dynamic roomID;
@dynamic sectionDate;
@dynamic seen;
@dynamic userId;
@dynamic uuid;

@end

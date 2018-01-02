//
//  Brand+CoreDataProperties.m
//  Status
//
//  Created by Cosmin Andrus on 31/12/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//
//

#import "Brand+CoreDataProperties.h"

@implementation Brand (CoreDataProperties)

+ (NSFetchRequest<Brand *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Brand"];
}

@dynamic uuid;
@dynamic image_url;
@dynamic name;
@dynamic indexString;

@end

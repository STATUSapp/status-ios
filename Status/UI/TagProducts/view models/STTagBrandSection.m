//
//  STTagBrandSection.m
//  Status
//
//  Created by Cosmin Andrus on 29/12/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STTagBrandSection.h"
#import "Brand+CoreDataClass.h"

@interface STTagBrandSection ()
@property (nonatomic, strong, readwrite) NSString *sectionName;
@property (nonatomic, strong, readwrite) NSArray<Brand *>*sectionItems;
@end

@implementation STTagBrandSection

-(instancetype)initWithSectionName:(NSString *)sectionName{
    if (!sectionName) {
        NSAssert(NO, @"Init With NULL sectionName is not supported");
        return nil;
    }
    self = [super init];
    if (self) {
        self.sectionName = sectionName;
    }
    return self;
}

-(instancetype)initWithObject:(Brand *)object{
    if (!object) {
        NSAssert(NO, @"Init With NULL object is not supported");
        return nil;
    }
    return [self initWithObjects:@[object]];
}
-(instancetype)initWithObjects:(NSArray <Brand *> *)objects{
    if (!objects || [objects count] == 0) {
        NSAssert(NO, @"Init With no objects is not supported");
        return nil;
    }
    self = [super init];
    if (self) {
        Brand *firstObject = [objects firstObject];
        self.sectionName = firstObject.indexString;
        [self addObjectsToItems:objects];
    }
    return self;
}

-(void)addObjectToItems:(Brand *)object{
    if (!object) {
        NSAssert(NO, @"Add NULL object is not supported");
        return;
    }
    [self addObjectsToItems:@[object]];
}
-(void)addObjectsToItems:(NSArray <Brand *> *)objects{
    if (!objects || [objects count] == 0) {
        NSAssert(NO, @"Add empty or NULL array is not supported");
        return;
    }
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.sectionItems];
    [array addObjectsFromArray:objects];
    self.sectionItems = [NSArray arrayWithArray:array];
}

@end

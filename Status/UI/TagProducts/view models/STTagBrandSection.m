//
//  STTagBrandSection.m
//  Status
//
//  Created by Cosmin Andrus on 29/12/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STTagBrandSection.h"
#import "STBrandObj.h"

@interface STTagBrandSection ()
@property (nonatomic, strong, readwrite) NSString *sectionName;
@property (nonatomic, strong, readwrite) NSArray<STBrandObj *>*sectionItems;
@end

@implementation STTagBrandSection
-(instancetype)initWithObject:(STBrandObj *)object{
    if (!object) {
        NSAssert(NO, @"Init With NULL object is not supported");
        return nil;
    }
    return [self initWithObjects:@[object]];
}
-(instancetype)initWithObjects:(NSArray <STBrandObj *> *)objects{
    if (!objects || [objects count] == 0) {
        NSAssert(NO, @"Init With no objects is not supported");
        return nil;
    }
    self = [super init];
    if (self) {
        STBrandObj *firstObject = [objects firstObject];
        self.sectionName = [firstObject.brandName substringToIndex:1];//first letter
        [self addObjectsToItems:objects];
    }
    return self;
}

-(void)addObjectToItems:(STBrandObj *)object{
    if (!object) {
        NSAssert(NO, @"Add NULL object is not supported");
        return;
    }
    [self addObjectsToItems:@[object]];
}
-(void)addObjectsToItems:(NSArray <STBrandObj *> *)objects{
    if (!objects || [objects count] == 0) {
        NSAssert(NO, @"Add empty or NULL array is not supported");
        return;
    }
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.sectionItems];
    [array addObjectsFromArray:objects];
    [array sortUsingComparator:^NSComparisonResult(STBrandObj *obj1, STBrandObj *obj2) {
        return [obj1.brandName compare:obj2.brandName];
    }];
    self.sectionItems = [NSArray arrayWithArray:array];
}

@end

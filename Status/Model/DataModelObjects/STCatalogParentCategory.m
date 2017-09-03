//
//  STCatalogParentCategory.m
//  Status
//
//  Created by Cosmin Andrus on 12/02/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STCatalogParentCategory.h"

@interface STCatalogParentCategory ()

@property (nonatomic, strong, readwrite) NSMutableArray <STCatalogCategory *>*categories;

@end

@implementation STCatalogParentCategory

+ (STCatalogParentCategory *)parentCategoryFromDict:(NSDictionary *)dict{
    STCatalogParentCategory *parentCategory = [STCatalogParentCategory new];
    parentCategory.uuid = [dict[@"id"] stringValue];
    parentCategory.name = dict[@"name"];
    
    return parentCategory;
}

-(void)addCategoryObjects:(NSArray <STCatalogCategory *> *)categpries{
    if (!_categories) {
        _categories = [NSMutableArray new];
    }
    
    [_categories addObjectsFromArray:categpries];
}

@end

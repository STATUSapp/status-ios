//
//  STCatalogParentCategory.m
//  Status
//
//  Created by Cosmin Andrus on 12/02/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STCatalogParentCategory.h"

@implementation STCatalogParentCategory

+ (STCatalogParentCategory *)parentCategoryFromDict:(NSDictionary *)dict{
    STCatalogParentCategory *parentCategory = [STCatalogParentCategory new];
    parentCategory.uuid = dict[@"id"];
    parentCategory.name = dict[@"name"];
    
    return parentCategory;
}

@end

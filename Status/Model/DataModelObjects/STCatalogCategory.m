//
//  STCatalogCategory.m
//  Status
//
//  Created by Cosmin Andrus on 12/02/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STCatalogCategory.h"

@implementation STCatalogCategory

+ (STCatalogCategory *)categoryFromDict:(NSDictionary *)dict{
    STCatalogCategory *category = [STCatalogCategory new];
    category.uuid = dict[@"id"];
    category.name = dict[@"name"];
    category.mainImageUrl = dict[@"image_url"];
    
    return category;
}


@end

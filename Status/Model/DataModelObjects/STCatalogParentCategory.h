//
//  STCatalogParentCategory.h
//  Status
//
//  Created by Cosmin Andrus on 12/02/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STBaseObj.h"
#import "STCatalogCategory.h"

@interface STCatalogParentCategory : STBaseObj

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong, readonly) NSMutableArray <STCatalogCategory *>*categories;

+ (STCatalogParentCategory *)parentCategoryFromDict:(NSDictionary *)dict;

-(void)addCategoryObjects:(NSArray <STCatalogCategory *> *)categpries;

@end

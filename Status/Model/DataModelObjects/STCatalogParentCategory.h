//
//  STCatalogParentCategory.h
//  Status
//
//  Created by Cosmin Andrus on 12/02/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STBaseObj.h"

@interface STCatalogParentCategory : STBaseObj

@property (nonatomic, strong) NSString *name;

+ (STCatalogParentCategory *)parentCategoryFromDict:(NSDictionary *)dict;
@end

//
//  STCatalogCategory.h
//  Status
//
//  Created by Cosmin Andrus on 12/02/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STBaseObj.h"

@interface STCatalogCategory : STBaseObj

@property (nonatomic, strong) NSString *name;

+ (STCatalogCategory *)categoryFromDict:(NSDictionary *)dict;

@end

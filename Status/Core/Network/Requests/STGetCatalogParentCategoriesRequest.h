//
//  STGetCatalogParentCategories.h
//  Status
//
//  Created by Cosmin Andrus on 12/02/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STGetCatalogParentCategoriesRequest : STBaseRequest

+ (void)getCatalogParentEntities:(STRequestCompletionBlock)completion
                         failure:(STRequestFailureBlock)failure;

@end

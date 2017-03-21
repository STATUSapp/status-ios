//
//  STGetUsedCatalogCategoriesRequest.h
//  Status
//
//  Created by Cosmin Andrus on 21/03/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STGetUsedCatalogCategoriesRequest : STBaseRequest
+ (void)getUsedCatalogCategoriesWithCompletion:(STRequestCompletionBlock)completion
                                       failure:(STRequestFailureBlock)failure;
@end

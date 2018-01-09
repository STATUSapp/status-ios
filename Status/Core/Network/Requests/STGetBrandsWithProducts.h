//
//  STGetBrandsWithProducts.h
//  Status
//
//  Created by Cosmin Andrus on 09/01/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STGetBrandsWithProducts : STBaseRequest

+ (void)getBrandsWithProductsForCategoryId:(NSString *)categoryId
                            withCompletion:(STRequestCompletionBlock)completion
                                   failure:(STRequestFailureBlock)failure;
@end

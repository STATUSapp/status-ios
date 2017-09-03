//
//  STGetUsedCatalogCategoriesRequest.h
//  Status
//
//  Created by Cosmin Andrus on 21/03/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STGetUsedCatalogCategoriesRequest : STBaseRequest
@property (nonatomic, assign) NSInteger pageIndex;

+ (void)getUsedCatalogCategoriesAtPageIndex:(NSInteger)pageIndex
                             withCompletion:(STRequestCompletionBlock)completion
                                    failure:(STRequestFailureBlock)failure;
@end

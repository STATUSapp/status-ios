//
//  STGetSuggestionsRequest.h
//  Status
//
//  Created by Cosmin Andrus on 21/03/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STGetSuggestionsRequest : STBaseRequest

@property (nonatomic, strong) NSString *categoryId;
@property (nonatomic, strong) NSString *brandId;
@property (nonatomic, assign) NSInteger pageIndex;

+ (void)getSuggestionsEntitiesForCategory:(NSString *)categoryId
                               andBrandId:(NSString *)brandId
                             andPageIndex:(NSInteger)pageIndex
                            andCompletion:(STRequestCompletionBlock)completion
                                  failure:(STRequestFailureBlock)failure;
@end

//
//  STGetUsedSuggestions.h
//  Status
//
//  Created by Cosmin Andrus on 21/03/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STGetUsedSuggestionsRequest : STBaseRequest
@property (nonatomic, strong) NSString *categoryId;
@property (nonatomic, assign) NSInteger pageIndex;

+ (void)getUsedSuggestionsEntitiesForCategory:(NSString *)categoryId
                                 andPageIndex:(NSInteger)pageIndex
                                andCompletion:(STRequestCompletionBlock)completion
                                      failure:(STRequestFailureBlock)failure;
@end

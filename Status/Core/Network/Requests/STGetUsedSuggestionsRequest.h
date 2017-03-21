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
+ (void)getUsedSuggestionsEntitiesForCategory:(NSString *)categoryId
                                andCompletion:(STRequestCompletionBlock)completion
                                      failure:(STRequestFailureBlock)failure;
@end

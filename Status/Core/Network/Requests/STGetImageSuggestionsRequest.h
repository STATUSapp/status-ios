//
//  STGetImageSuggestions.h
//  Status
//
//  Created by Cosmin Andrus on 28/02/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STGetImageSuggestionsRequest : STBaseRequest

+ (void)getPostSuggestionsForId:(NSString *)postId
                  andCompletion:(STRequestCompletionBlock)completion
                        failure:(STRequestFailureBlock)failure;

@end

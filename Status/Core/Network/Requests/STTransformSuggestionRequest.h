//
//  STTransformSuggestionRequest.h
//  Status
//
//  Created by Cosmin Andrus on 18/05/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STTransformSuggestionRequest : STBaseRequest

+ (void)transformSuggestedProductId:(NSString *)suggestionId
                          forPostId:(NSString *)postId
                      andCompletion:(STRequestCompletionBlock)completion
                            failure:(STRequestFailureBlock)failure;
@end

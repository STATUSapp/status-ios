//
//  STTransformSuggestionRequest.h
//  Status
//
//  Created by Cosmin Andrus on 18/05/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"
@class STSuggestedProduct;
@interface STTransformSuggestionsRequest : STBaseRequest

+ (void)transformSuggestions:(NSArray<STSuggestedProduct *> *)suggestions
                   forPostId:(NSString *)postId
               andCompletion:(STRequestCompletionBlock)completion
                     failure:(STRequestFailureBlock)failure;
@end

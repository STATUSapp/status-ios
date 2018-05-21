//
//  STUploadImageForSuggestions.h
//  Status
//
//  Created by Cosmin Andrus on 28/02/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STUploadImageForSuggestionsRequest : STBaseRequest

+ (void)uploadImageForSuggestionsWithData:(NSData*)imageData
                                forPostId:(NSString *)postId
                           withCompletion:(STRequestCompletionBlock)completion
                                  failure:(STRequestFailureBlock)failure;
@end

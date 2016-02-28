//
//  STUpdatePostCaptionRequest.h
//  Status
//
//  Created by Cosmin Andrus on 1/14/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STUpdatePostCaptionRequest : STBaseRequest
@property(nonatomic, strong)NSString *postId;
@property(nonatomic, strong)NSString *caption;
+ (void)setPostCaption:(NSString *)capion
             forPostId:(NSString *)postId
        withCompletion:(STRequestCompletionBlock)completion
               failure:(STRequestFailureBlock)failure;
@end

//
//  STSetPostLike.h
//  Status
//
//  Created by Cosmin Andrus on 22/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STSetPostLikeRequest : STBaseRequest
@property(nonatomic, strong)NSString *postId;
+ (void)setPostLikeForPostId:(NSString *)postId
              withCompletion:(STRequestCompletionBlock)completion
                     failure:(STRequestFailureBlock)failure;
@end

//
//  STSetPostSeenRequest.h
//  Status
//
//  Created by Cosmin Andrus on 27/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STSetPostSeenRequest : STBaseRequest
@property(nonatomic, strong) NSString *postId;
+ (void)setPostSeen:(NSString*)postId
     withCompletion:(STRequestCompletionBlock)completion
            failure:(STRequestFailureBlock)failure;

@end

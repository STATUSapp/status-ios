//
//  STRepostPostRequest.h
//  Status
//
//  Created by Cosmin Andrus on 23/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STRepostPostRequest : STBaseRequest
@property (nonatomic, strong) NSString *postId;
+ (void)reportPostWithId:(NSString *)postId
          withCompletion:(STRequestCompletionBlock)completion
                 failure:(STRequestFailureBlock)failure;
@end

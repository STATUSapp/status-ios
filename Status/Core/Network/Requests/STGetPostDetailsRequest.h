//
//  STGetPostDetails.h
//  Status
//
//  Created by Cosmin Andrus on 30/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STGetPostDetailsRequest : STBaseRequest
@property(nonatomic, strong)NSString *postId;
+ (void)getPostDetails:(NSString*)postId
        withCompletion:(STRequestCompletionBlock)completion
               failure:(STRequestFailureBlock)failure;
@end

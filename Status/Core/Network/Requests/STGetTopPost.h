//
//  STGetTopPost.h
//  Status
//
//  Created by Cosmin Andrus on 05/08/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STGetTopPost : STBaseRequest

+ (void)getTopPostForPostId:(NSString*)postId
                   andTopId:(NSString *)topId
             withCompletion:(STRequestCompletionBlock)completion
                    failure:(STRequestFailureBlock)failure;

@end

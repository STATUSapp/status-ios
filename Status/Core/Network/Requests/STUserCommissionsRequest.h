//
//  STGetUserCommissions.h
//  Status
//
//  Created by Cosmin Andrus on 05/07/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STUserCommissionsRequest : STBaseRequest

+ (void)getUserCommissionsWithCompletion:(STRequestCompletionBlock)completion
                                 failure:(STRequestFailureBlock)failure;

+ (void)withdrawnUserCommissionsWithCompletion:(STRequestCompletionBlock)completion
                                       failure:(STRequestFailureBlock)failure;

@end

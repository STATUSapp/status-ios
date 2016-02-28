//
//  STGetUserSettingsRequest.h
//  Status
//
//  Created by Cosmin Andrus on 30/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STGetUserSettingsRequest : STBaseRequest
+ (void)getUserSettingsWithCompletion:(STRequestCompletionBlock)completion
                              failure:(STRequestFailureBlock)failure;
@end

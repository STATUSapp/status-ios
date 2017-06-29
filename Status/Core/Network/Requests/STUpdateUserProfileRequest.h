//
//  STUpdateUserProfileRequest.h
//  Status
//
//  Created by Silviu Burlacu on 28/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"
#import "STUserProfile.h"

@interface STUpdateUserProfileRequest : STBaseRequest

+ (void)updateUserProfileWithProfile:(STUserProfile *)userProfile
                      withCompletion:(STRequestCompletionBlock)completion
                             failure:(STRequestFailureBlock)failure;

@end

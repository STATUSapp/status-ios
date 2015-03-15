//
//  STUpdateUserProfileRequest.h
//  Status
//
//  Created by Silviu Burlacu on 28/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STUpdateUserProfileRequest : STBaseRequest

@property (strong, nonatomic) NSDictionary * paramsDict;

+ (void)updateUserProfileWithFirstName:(NSString *)name
                              lastName:(NSString *)lastName
                              fullName:(NSString *)fullName
                          homeLocation:(NSString *)location
                                   bio:(NSString *)bio
                        withCompletion:(STRequestCompletionBlock)completion
                               failure:(STRequestFailureBlock)failure;

@end

//
//  STGetSuggestUsers.h
//  Status
//
//  Created by Cosmin Adelin Andrus on 17/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STGetSuggestUsersRequest : STBaseRequest
@property (nonatomic, strong) NSNumber *offset;
+ (void)getSuggestUsersWithOffset:(NSNumber *)offset
                   withCompletion:(STRequestCompletionBlock)completion
                          failure:(STRequestFailureBlock)failure;

@end

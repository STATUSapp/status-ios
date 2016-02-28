//
//  STGetFollowersRequest.h
//  Status
//
//  Created by Silviu Burlacu on 07/06/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STGetFollowersRequest : STBaseRequest
@property (nonatomic, strong) NSNumber *offset;
@property (nonatomic, strong) NSString *userID;
+ (void)getFollowersForUser:(NSString *)userID withOffset:(NSNumber *)offset
             withCompletion:(STRequestCompletionBlock)completion
                    failure:(STRequestFailureBlock)failure;
@end

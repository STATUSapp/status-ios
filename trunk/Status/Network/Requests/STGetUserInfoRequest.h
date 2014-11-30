//
//  STGetUserInfoRequest.h
//  Status
//
//  Created by Cosmin Andrus on 30/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STGetUserInfoRequest : STBaseRequest
@property(nonatomic, strong)NSString *userId;
+ (void)getInfoForUser:(NSString *)userId
            completion:(STRequestCompletionBlock)completion
               failure:(STRequestFailureBlock)failure;
@end

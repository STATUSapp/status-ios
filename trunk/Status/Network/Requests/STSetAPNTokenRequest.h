//
//  STSetAPNTokenRequest.h
//  Status
//
//  Created by Cosmin Andrus on 30/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STSetAPNTokenRequest : STBaseRequest
@property(nonatomic, strong) NSString *apnToken;
+ (void)setAPNToken:(NSString*)apnToken
     withCompletion:(STRequestCompletionBlock)completion
            failure:(STRequestFailureBlock)failure;
@end

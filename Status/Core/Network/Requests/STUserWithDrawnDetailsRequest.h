//
//  STUserWithDrawnDetailsRequest.h
//  Status
//
//  Created by Cosmin Andrus on 05/07/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@class STWithdrawDetailsObj;
@interface STUserWithDrawnDetailsRequest : STBaseRequest

+ (void)getUserWithdrawnDetailsWithCompletion:(STRequestCompletionBlock)completion
                                      failure:(STRequestFailureBlock)failure;

+ (void)postUserWithdrawnDetails:(STWithdrawDetailsObj *)withdrawObj
                  withCompletion:(STRequestCompletionBlock)completion
                         failure:(STRequestFailureBlock)failure;

@end

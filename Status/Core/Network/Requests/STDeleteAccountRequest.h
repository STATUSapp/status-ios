//
//  STDeleteAccountRequest.h
//  Status
//
//  Created by Cosmin Andrus on 20/05/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STDeleteAccountRequest : STBaseRequest

+ (void)deleteAccountWithCompletion:(STRequestCompletionBlock)completion
                            failure:(STRequestFailureBlock)failure;

@end

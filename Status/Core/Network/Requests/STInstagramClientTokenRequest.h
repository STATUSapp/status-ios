//
//  STInstagramTemporaryToken.h
//  Status
//
//  Created by Cosmin Andrus on 17/06/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STInstagramClientTokenRequest : STBaseRequest

+ (void)getClientInstagramTokenWithCompletion:(STRequestCompletionBlock)completion
                                      failure:(STRequestFailureBlock)failure;
@end

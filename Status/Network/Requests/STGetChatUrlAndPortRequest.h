//
//  STGetChatUrlAndPortRequest.h
//  Status
//
//  Created by Cosmin Adelin Andrus on 27/09/15.
//  Copyright © 2015 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STGetChatUrlAndPortRequest : STBaseRequest
+ (void)getReconnectInfoWithCompletion:(STRequestCompletionBlock)completion
                               failure:(STRequestFailureBlock)failure;
@end

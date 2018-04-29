//
//  STSendLogsReguest.h
//  Status
//
//  Created by Cosmin Andrus on 20/04/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STSendLogsReguest : STBaseRequest
+ (void)sendLogs:(NSDictionary *)logs
   andCompletion:(STRequestCompletionBlock)completion
         failure:(STRequestFailureBlock)failure;

@end

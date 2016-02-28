//
//  STFlowImagesRequest.h
//  Status
//
//  Created by Cosmin Adelin Andrus on 01/08/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STFlowImagesRequest : STBaseRequest
+ (void)getFlowImagesWithCompletion:(STRequestCompletionBlock)completion
                            failure:(STRequestFailureBlock)failure;
@end

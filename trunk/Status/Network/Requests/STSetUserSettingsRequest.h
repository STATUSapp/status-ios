//
//  STSetUserSettingsRequest.h
//  Status
//
//  Created by Cosmin Andrus on 30/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STSetUserSettingsRequest : STBaseRequest
@property(nonatomic, strong) NSString *key;
@property(nonatomic, assign) BOOL value;
+ (void)setSettingsValue:(BOOL)value
                  forKey:(NSString *)key
          withCompletion:(STRequestCompletionBlock)completion
                 failure:(STRequestFailureBlock)failure;
@end

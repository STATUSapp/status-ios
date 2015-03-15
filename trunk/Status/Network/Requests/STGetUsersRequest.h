//
//  STGetUsersRequest.h
//  Status
//
//  Created by Cosmin Andrus on 30/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STGetUsersRequest : STBaseRequest
@property(nonatomic, assign) STSearchScopeControl scope;
@property(nonatomic, strong) NSString *searchText;
@property(nonatomic, assign) NSInteger offset;

+ (void)getUsersForScope:(STSearchScopeControl)scope
          withSearchText:(NSString *)searchText
               andOffset:(NSInteger)offset
              completion:(STRequestCompletionBlock)completion
                 failure:(STRequestFailureBlock)failure;
@end

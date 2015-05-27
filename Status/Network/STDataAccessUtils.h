//
//  STDataAccessUtils.h
//  Status
//
//  Created by Cosmin Adelin Andrus on 17/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STRequests.h"

typedef void (^STDataAccessCompletionBlock)(NSArray *objects, NSError *error);

@interface STDataAccessUtils : NSObject

+(void)getSuggestUsersWithOffset:(NSNumber *)offset
                   andCompletion:(STDataAccessCompletionBlock)completion;

@end
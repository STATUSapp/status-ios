//
//  STDataAccessUtils.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 17/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STDataAccessUtils.h"
#import "STDataModelObjects.h"

@implementation STDataAccessUtils
+(void)getSuggestUsersWithOffset:(NSNumber *)offset
                   andCompletion:(STDataAccessCompletionBlock)completion{
    [STGetSuggestUsersRequest getSuggestUsersWithOffset:offset withCompletion:^(id response, NSError *error) {
        if (error!=nil) {
            completion(nil, error);
        }
        else
        {
            NSMutableArray *objects = [NSMutableArray new];
            for (NSDictionary *dict in response[@"data"]) {
                STSuggestedUser *su = [STSuggestedUser suggestedUserWithDict:dict];
                [objects addObject:su];
            }
            completion([NSArray arrayWithArray:objects], nil);
            
        }
        
    } failure:^(NSError *error) {
        completion(nil, error);
    }];
}
@end

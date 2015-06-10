//
//  STFollowDataProcessor.h
//  Status
//
//  Created by Cosmin Adelin Andrus on 01/06/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STDataAccessUtils.h"

@interface STFollowDataProcessor : NSObject
-(instancetype)initWithUsers:(NSArray *)users;

- (void)setUsers:(NSArray *)users;

-(void)uploadDataToServer:(NSArray *)newData
           withCompletion:(STDataUploadCompletionBlock)completion;
@end

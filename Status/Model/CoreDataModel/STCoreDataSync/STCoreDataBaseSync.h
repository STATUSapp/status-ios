//
//  STCoreDataBaseSync.h
//  Status
//
//  Created by Cosmin Andrus on 31/12/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STCoreDataRequestManager.h"
#import "STDAOEngine.h"
#import "CreateDataModelHelper.h"

typedef void (^syncCompletion)(NSError *error, NSManagedObject *object);

@interface STCoreDataBaseSync : NSObject

- (void)synchronizeAsyncCoreDataFromData:(NSDictionary*)serverData
                          withCompletion:(syncCompletion)completion;


@end

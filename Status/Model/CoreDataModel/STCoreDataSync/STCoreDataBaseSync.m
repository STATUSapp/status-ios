//
//  STCoreDataBaseSync.m
//  Status
//
//  Created by Cosmin Andrus on 31/12/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STCoreDataBaseSync.h"
#import "STCoreDataManager.h"
#import "CreateDataModelHelper.h"

@implementation STCoreDataBaseSync

-(NSManagedObjectContext *)getNewManagedObjectContext{
    return [[CoreManager coreDataService] getNewManagedObjectContext];
}

- (void)synchronizeAsyncCoreDataFromData:(NSDictionary*)serverData
                          withCompletion:(syncCompletion)completion{
    //We create a new managed object context from our main, we update it async, then we merge the changes into our main M.O.C
    // Create a new managed object context
    // Set its persistent store coordinator
    NSManagedObjectContext *newMoc = [self getNewManagedObjectContext];
    NSManagedObject *fetchObject = [self fetchObjectForUuid:[CreateDataModelHelper validStringIdentifierFromValue:serverData[@"id"]]];
    
    if (fetchObject==nil) {
        //insert
        [newMoc performBlock:^{
            NSManagedObject *insertedValue = [[CoreManager coreDataService] insertDataForTableName:[self entityName] inObjectContext:newMoc];
            [self configureManagedObject:insertedValue
                                withData:serverData];
            NSError *error = nil;
            [newMoc save:&error];
            
            if (error) {
                NSLog(@"synchronizeAsyncCoreDataEntity error: %@",error);
            }
            if (completion) {
                completion(error, insertedValue);
            }
        }];
    }else{
        //update
        [newMoc performBlock:^{
            [self configureManagedObject:fetchObject
                                withData:serverData];
            NSError *error = nil;
            [newMoc save:&error];
            
            if (error) {
                NSLog(@"synchronizeAsyncCoreDataEntity error: %@",error);
            }
            if (completion) {
                completion(error, fetchObject);
            }
        }];

    }
}

#pragma mark - Hook methods

-(NSManagedObject *)fetchObjectForUuid:(NSString *)objectuuid{
    NSAssert(NO, @"This method \"fetchObjectForUuid:\" should be implemented in subclasess");
    return nil;
}

-(NSString *)entityName{
    NSAssert(NO, @"This method \"entityName\" should be implemented in subclasess");
    return nil;
}

-(void)configureManagedObject:(NSManagedObject *)object
                    withData:(NSDictionary *)serverData{
    NSAssert(NO, @"This method \"configureManagedObject:withData:\" should be implemented in subclasess");
    return;
}
@end

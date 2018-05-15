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

- (void)synchronizeAsyncCoreDataFromData:(NSArray*)serverData
                          withCompletion:(syncCompletion)completion{
    //We create a new managed object context from our main, we update it async, then we merge the changes into our main M.O.C
    // Create a new managed object context
    // Set its persistent store coordinator
    NSManagedObjectContext *newMoc = [self getNewManagedObjectContext];
    __weak STCoreDataBaseSync *weakSelf = self;
    [newMoc performBlock:^{
        __strong STCoreDataBaseSync *strongSelf = weakSelf;
        for (NSDictionary *itemDict in serverData) {
            NSManagedObject *fetchObject = [strongSelf fetchObjectForUuid:[CreateDataModelHelper validStringIdentifierFromValue:itemDict[@"id"]] inContext:newMoc];
            
            if (fetchObject==nil) {
                //insert
                NSManagedObject *insertedValue = [[CoreManager coreDataService] insertDataForTableName:[strongSelf entityName] inObjectContext:newMoc];
                [strongSelf configureManagedObject:insertedValue
                                    withData:itemDict];
            }else{
                //update
                [strongSelf configureManagedObject:fetchObject
                                    withData:itemDict];
            }
        }
        NSError *error = nil;
        [newMoc save:&error];
        
        if (error) {
            NSLog(@"synchronizeAsyncCoreDataEntity error: %@",error);
        }
        if (completion) {
            completion(error);
        }
    }];
}

#pragma mark - Hook methods

-(NSManagedObject *)fetchObjectForUuid:(NSString *)objectuuid
                             inContext:(NSManagedObjectContext *)context{
    NSAssert(NO, @"This method \"fetchObjectForUuid:inContext:\" should be implemented in subclasess");
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

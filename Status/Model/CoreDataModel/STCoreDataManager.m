//
//  STCoreDataManager.m
//  Status
//
//  Created by Andrus Cosmin on 25/07/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STCoreDataManager.h"
#import "Message.h"
#import "STDAOEngine.h"
#import "CreateDataModelHelper.h"

//Set the name of your xcdatamodeld file
NSString* const kCoreDataModelFileName = @"StatusDM";

NSString* const kSqliteFileName = @"Status.sqlite";

//Set the name of the sqlite file in which CoreData will persist information

@implementation STCoreDataManager{
    dispatch_queue_t _async_queries_queue;
    
    NSArray *_arrDateKeys;
}

static STCoreDataManager* _coreDataManager = nil;

+ (STCoreDataManager*)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
         _coreDataManager = [[STCoreDataManager alloc] init];
    });

    return _coreDataManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        [self managedObjectContext];
        _async_queries_queue = dispatch_queue_create("com.status.async_queries_queue", NULL);
    }
    return self;
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:kCoreDataModelFileName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // Returns the persistent store coordinator for the application. If the coordinator doesn't already exist, it is created and the application's store added to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kSqliteFileName];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSError *error;
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@YES,
                              NSInferMappingModelAutomaticallyOption:@YES};
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil
                                                             URL:storeURL options:options error:&error]) {
        NSLog(@"Error 1:%@, %@", error, [error userInfo]);
        error = nil;
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
        if (error) {
            NSLog(@"Error deleting old db file:%@, %@", error, [error userInfo]);
        }
        error = nil;
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            NSLog(@"Error 2:%@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    return _persistentStoreCoordinator;
}


#pragma mark -
#pragma mark - Delete data

- (void)cleanLocalDataBase{
    
    self.managedObjectContext = nil;
    
    //Cancel all request
    
    NSPersistentStore *store = [_persistentStoreCoordinator.persistentStores objectAtIndex:0];
    NSError *error;
    NSURL *storeURL = store.URL;
    [_persistentStoreCoordinator removePersistentStore:store error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
    
    _persistentStoreCoordinator = nil;
    
    [self managedObjectContext];
}

- (void)deleteAllObjectsFromTable:(NSString *)tableName withPredicate:(NSPredicate*)predicate{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:tableName inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    if (predicate) {
        [fetchRequest setPredicate:predicate];
    }
    
    NSError *error;
    NSArray *items = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"error deleting objectFromTable = %@, table =%@", error.description, tableName);
    }
    
    for (NSManagedObject *managedObject in items) {
        [_managedObjectContext deleteObject:managedObject];
    }
}

#pragma mark - Get data main methods

- (NSArray*)fetchDataWithParameterBlock:(ParameterBlock)parameterBlock andTableName:(NSString*)tableName{
    return [self fetchDataWithParameterBlock:^(NSFetchRequest *requestToBeParametered) {
        if (parameterBlock) parameterBlock(requestToBeParametered);
    } andTableName:tableName inObjectContext:self.managedObjectContext];
}

- (void)fetchDataAsyncWithParameterBlock:(ParameterBlock)parameterBlock andTableName:(NSString*)tableName andCompletion:(CompletionBlock)completionBlock{
    
    dispatch_async(_async_queries_queue, ^{
        
        // Create a new managed object context
        // Set its persistent store coordinator
        NSArray *array = [self fetchDataWithParameterBlock:^(NSFetchRequest *requestToBeParametered) {
            parameterBlock(requestToBeParametered);
        } andTableName:tableName inObjectContext:self.managedObjectContext];
        
        if (array.count > 0)
            completionBlock(YES,array);
        else completionBlock(NO,array);
    });
}


#pragma mark - Get data helpers

- (NSArray*)fetchDataWithParameterBlock:(ParameterBlock)parameterBlock andTableName:(NSString*)tableName inObjectContext:(NSManagedObjectContext*)managedObjectContext{
    
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    if (parameterBlock) parameterBlock(fetchRequest);
    NSEntityDescription *entity = [NSEntityDescription entityForName:tableName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error) NSLog(@"Fetch request failed");
    else return array;
    
    return nil;
}

#pragma mark - Insert data

- (id)insertDataForTableName:(NSString*)tableName{
    id managedObject = nil;
    managedObject = [NSEntityDescription insertNewObjectForEntityForName:tableName inManagedObjectContext:self.managedObjectContext];
    return managedObject;
}

#pragma mark - Insert data helpers

- (id)insertDataForTableName:(NSString *)tableName inObjectContext:(NSManagedObjectContext*)managedObjectContext{
    id managedObject = nil;
    managedObject = [NSEntityDescription insertNewObjectForEntityForName:tableName inManagedObjectContext:managedObjectContext];
    return managedObject;
}

#pragma mark - Update data

- (void)synchronizeAsyncCoreDataEntity:(NSString*)entityName
                              withData:(NSDictionary*)serverData
                         andCompletion:(CompletionBlock)completion{
    //We create a new managed object context from our main, we update it async, then we merge the changes into our main M.O.C
    // Create a new managed object context
    // Set its persistent store coordinator
    NSManagedObjectContext *newMoc = [self getNewManagedObjectContext];
    NSSortDescriptor *sd1 = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    
    STCoreDataRequestManager *messageManager = [[STDAOEngine sharedManager] fetchRequestManagerForEntity:@"Message" sortDescritors:@[sd1] predicate:[NSPredicate predicateWithFormat:@"uuid like %@", [CreateDataModelHelper validStringIdentifierFromValue:serverData[@"id"]]] sectionNameKeyPath:nil delegate:nil andTableView:nil];
    
    Message *message = [[messageManager allObjects] lastObject];
    if (message==nil) {
        [newMoc performBlock:^{
            Message *insertedValue = [self insertDataForTableName:entityName inObjectContext:newMoc];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
            NSDate* date = [dateFormatter dateFromString:serverData[@"date"]];
            insertedValue.date = date;
            insertedValue.message = serverData[@"message"];
            insertedValue.received = serverData[@"received"];
            insertedValue.roomID = serverData[@"roomID"];
            insertedValue.seen = serverData[@"seen"];
            insertedValue.userId = [CreateDataModelHelper validStringIdentifierFromValue:serverData[@"userId"]];
            insertedValue.uuid = [CreateDataModelHelper validStringIdentifierFromValue: serverData[@"id"]];
            
            NSError *error = nil;
            [newMoc save:&error];
            
            if (error) {
                NSLog(@"synchronizeAsyncCoreDataEntity error: %@",error);
                if (completion) {
                    completion(NO,error);
                }
            }
            else {
                if (completion) {
                    completion(YES,newMoc);
                }
            }
            
        }];
    }
}

#pragma mark -  Update data helpers

- (void)save{
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    
    if (error) NSLog(@"Could not save changes to database: %@",error);
}

#pragma mark - Get a managed object context

- (NSManagedObjectContext*)getNewManagedObjectContext{
    // Create a new managed object context
    // Set its persistent store coordinator
    NSManagedObjectContext *newMoc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [newMoc setParentContext:self.managedObjectContext];
    
    return newMoc;

}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Object Version Check
-(BOOL)hasObjectVersionForDBObject:(id) objectFromDB
                      serverObject:(id)objectFromServer
                 canChangeStatuses:(BOOL)canChangeStatuses{

    return NO;
    
}

@end

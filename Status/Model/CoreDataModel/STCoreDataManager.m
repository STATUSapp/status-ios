//
//  STCoreDataManager.m
//  Status
//
//  Created by Andrus Cosmin on 25/07/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STCoreDataManager.h"
#import "Message+CoreDataClass.h"
#import "STDAOEngine.h"
#import "CreateDataModelHelper.h"

//Set the name of your xcdatamodeld file
NSString* const kCoreDataModelFileName = @"StatusDM";

NSString* const kSqliteFileName = @"Status.sqlite";

//Set the name of the sqlite file in which CoreData will persist information

@interface STCoreDataManager ()

@property (strong, nonatomic) NSManagedObjectContext *privateContext;

@property (strong, nonatomic, readwrite) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic, readwrite) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic, readwrite) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation STCoreDataManager{
    dispatch_queue_t _async_queries_queue;    
}

- (id)init
{
    self = [super init];
    if (self) {
        
        [self initializeCoreData];
        _async_queries_queue = dispatch_queue_create("com.status.async_queries_queue", NULL);
    }
    return self;
}

#pragma mark - Core Data stack

- (void)initializeCoreData
{
    if ([self managedObjectContext]) return;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:kCoreDataModelFileName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSAssert(_managedObjectModel, @"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
    NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSAssert(_persistentStoreCoordinator, @"Failed to initialize coordinator");
    NSLog(@"Failed to initialize coordinator");
    [self setManagedObjectContext:[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType]];
    
    [self setPrivateContext:[[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType]];
    [[self privateContext] setPersistentStoreCoordinator:_persistentStoreCoordinator];
    [[self managedObjectContext] setParentContext:[self privateContext]];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSPersistentStoreCoordinator *psc = [[self privateContext] persistentStoreCoordinator];
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        options[NSMigratePersistentStoresAutomaticallyOption] = @YES;
        options[NSInferMappingModelAutomaticallyOption] = @YES;
        options[NSSQLitePragmasOption] = @{ @"journal_mode":@"DELETE" };
    
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *storeURL = [documentsURL URLByAppendingPathComponent:kSqliteFileName];
        
        NSError *error = nil;
        BOOL result = ([psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]!=nil);
        NSAssert(result, @"Error initializing PSC: %@\n%@", [error localizedDescription], [error userInfo]);
    NSLog(@"RESULT: %@\nError initializing PSC: %@\n%@",@(result), [error localizedDescription], [error userInfo]);
//    });
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
    
    [self initializeCoreData];
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

#pragma mark -  Update data helpers

- (void)save;
{
    if (![[self privateContext] hasChanges] && ![[self managedObjectContext] hasChanges]) return;
    
    [[self managedObjectContext] performBlockAndWait:^{
        NSError *error = nil;
        __block BOOL result = [[self managedObjectContext] save:&error];
        NSAssert(result, @"Failed to save main context: %@\n%@", [error localizedDescription], [error userInfo]);
        NSLog(@"RESULT: %@\nFailed to save main context: %@\n%@", @(result), [error localizedDescription], [error userInfo]);
        [[self privateContext] performBlock:^{
            NSError *privateError = nil;
            result = [[self privateContext] save:&privateError];
            NSAssert(result, @"Error saving private context: %@\n%@", [privateError localizedDescription], [privateError userInfo]);
            NSLog(@"RESULT: %@\nError saving private context: %@\n%@", @(result), [privateError localizedDescription], [privateError userInfo]);
        }];
    }];
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

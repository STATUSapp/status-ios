//
//  SLCoreDataManager.m
//  Solum
//
//  Created by Cosmin Andrus on 10/25/13.
//  Copyright (c) 2013
//
/**
 *  SLCoreDataManager ... Handles basic database operations like : Add, Retrieve and Delete Data
 */

//TODO: clean for unused methods

#import "STCoreDataManager.h"
#import "Message.h"

//Set the name of your xcdatamodeld file
NSString* const kCoreDataModelFileName = @"StatusDM";

NSString* const kSqliteFileName = @"Status.sqlite";

//Set the name of the sqlite file in which CoreData will persist information

@implementation STCoreDataManager{
    dispatch_queue_t _async_queries_queue;
    
    NSArray *_arrDateKeys;
    
    //table -> relationship -> toTable
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


#pragma mark - Utility
-(BOOL) isDateKey:(NSString*)key {
    for (NSString *dateKey in _arrDateKeys) {
        if ([dateKey isEqualToString:key]) {
            return YES;
        }
    }
    return NO;
}

-(BOOL) isNSDataKey:(NSString*)key {
    if ([key isEqualToString:@"task_attribute"] ||
        [key isEqualToString:@"shape"]||
        [key isEqualToString:@"seed_attributes"]) {
        return YES;
    }
    return NO;
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

/*
// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kSqliteFileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
        
        //TODO:Preload existing data here is needed
 
//         NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ContactsLoading" ofType:@"sqlite"]];
//         NSError* err = nil;
//         
//         if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&err]) {
//         DDLogWarn(@"Oops, could copy preloaded data");
//         }
    }
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _persistentStoreCoordinator;
}
*/


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

- (void)insertDataAsync:(NSArray*)dataArray
           forTableName:(NSString*)tableName
        withUpdateBlock:(UpdateBlock)updateBlock
          andCompletion:(CompletionBlock)completionBlock
{
    //The idea begin this is
    //We create a new managed object context from our main, we update it async, then we merge the changes into our main M.O.C
    dispatch_async(_async_queries_queue, ^{
        
        // Create a new managed object context
        // Set its persistent store coordinator
        NSManagedObjectContext *newMoc = [self getNewManagedObjectContext];
        __block id insertedObject;
        __block NSError *error = nil;

        [newMoc performBlock:^{
            // Do the work
            for (int i = 0; i < dataArray.count; i++){
                insertedObject = [self insertDataForTableName:tableName inObjectContext:newMoc];
                id updateData = dataArray[i];
                updateBlock(insertedObject,updateData);
            }
            // Call save on context (this will send a save notification and call the method below)
            [newMoc save:&error];
        }];
        if (error)
            completionBlock(NO,error);
        else completionBlock(YES,insertedObject);
    });
}

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
    dispatch_async(_async_queries_queue, ^{
        
        // Create a new managed object context
        // Set its persistent store coordinator
        NSManagedObjectContext *newMoc = [self getNewManagedObjectContext];
        
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
        insertedValue.userId = serverData[@"userId"];
        
        NSError *error = nil;
        [newMoc save:&error];

        if (error) {
            NSLog(@"synchronizeAsyncCoreDataEntity error: %@",error);
            completion(NO,error);
        }
        else completion(YES,newMoc);
    });
}

- (void)synchronizeCoreDataEntity:(NSString*)entityName
                         withData:(NSArray*)serverData
{
    [self syncronizeDBEntities:entityName
                       forData:serverData
               inObjectContext:self.managedObjectContext];
}

- (void)syncronizeDBEntities:(NSString*)entityName
                     forData:(NSArray*)serverData
             inObjectContext:(NSManagedObjectContext*)context
{
    
    [[STCoreDataManager sharedManager] updateDataWithBlock:^(id objectFromDB, id objectFromServer) {
        
        [self convertJSONDataToDBObjects:objectFromServer
                               forEntity:objectFromDB
                           andEntityName:entityName
                         inObjectContext:context];
        
    } andResults:serverData fromTable:entityName withPrimaryKey:@"uuid"
      andBatchSize:500 inObjectContext:context];
    
}

#pragma mark - Update data JSON-DBObject conversion

- (void)convertJSONDataToDBObjects:(id)serverData
                         forEntity:(id)dbObject
                     andEntityName:(NSString*)entityName
                   inObjectContext:(NSManagedObjectContext*)context {
    
    NSManagedObject *managedObject = (NSManagedObject*)dbObject;
    
    NSArray *entityKeys = [[[managedObject entity] attributesByName] allKeys];
    
    NSArray *serverDataKeys = [serverData allKeys];
    for (NSString *key in serverDataKeys){
        NSObject *dictionaryObject = [serverData objectForKey:key];
        if ([dictionaryObject isKindOfClass:[NSNull class]]) {
            continue;
        }
        NSString *managedObjKey = key;

        //alter keys here
        if ([key isEqualToString:@"id"]) {
            managedObjKey = @"uuid";
        }
        
        if ([key isEqualToString:@"description"]) {
            managedObjKey = @"descr";
        }
        
        if ([key isEqualToString:@"resource_api"]) {
            managedObjKey = @"resource";
        }

        //Safe check if db object has a key
        if ([entityKeys indexOfObject:managedObjKey] != NSNotFound){
            if ([self isDateKey:managedObjKey])
                [self convertDateWithDicObject:(NSString*)dictionaryObject
                                 managedObjKey:managedObjKey
                                 managedObject:managedObject];
            else
                [self convertJSONUpdateWithDicObject:dictionaryObject managedObjKey:managedObjKey
                                       managedObject:managedObject inObjectContext:context entityName:entityName key:key];
            
            //Check if db object has this relationship
        }
    }
}

-(void)convertDateWithDicObject:(NSString*)dictionaryObject
                  managedObjKey:(NSString*)managedObjKey
                  managedObject:(NSManagedObject*)managedObject{
    //date looks like this: 2013-12-01T21:19:56.629107-08:00
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    NSDate* date = [dateFormatter dateFromString:(NSString*)dictionaryObject];
    date = [dateFormatter dateFromString:(NSString*)dictionaryObject];

    [managedObject setValue:date forKey:managedObjKey];
}

-(void)convertJSONUpdateWithDicObject:(id)dictionaryObject
                        managedObjKey:(NSString*)managedObjKey
                        managedObject:(NSManagedObject*)managedObject
                      inObjectContext:(NSManagedObjectContext*)managedObjectContext
                           entityName:(NSString*)entityName
                                  key:(NSString*)key{
    //Update the object here
    if ([dictionaryObject isKindOfClass:[NSDictionary class]]) {
        //save this as a JSON
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionaryObject options:NSJSONWritingPrettyPrinted error:&error];
        if (!error) {
            if([self isNSDataKey:managedObjKey]) {
                //this is for keeping JSON representations as NSData
                [managedObject setValue:jsonData forKey:managedObjKey];
            }
            else {
                NSString* jsonStr = [[NSString alloc] initWithData:jsonData
                                                          encoding:NSUTF8StringEncoding];
                [managedObject setValue:jsonStr forKey:managedObjKey];
            }
        }
        
    }
}
#pragma mark -  Update data helpers

- (void)updateDataWithBlock:(UpdateBlock)updateBlock
                 andResults:(NSArray *)results
                  fromTable:(NSString *)tableName
             withPrimaryKey:(NSString *)primaryKey
               andBatchSize:(int)batchSize
            inObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    
    NSUInteger count = results.count;
    NSUInteger batchesNumber = count / batchSize;
    batchesNumber += count % batchSize > 0 ? 1 : 0;
    
    NSArray *subResults;
    NSArray *matchesFromDB;
    
    NSEnumerator *enumeratedResults;
    NSEnumerator *enumeratedMatches ;
    
    //if primaryKey is uuid, then from search results, get primary key id
    NSString *serverDataKey = primaryKey;
    
    NSArray *sortedResults = results;
    if ([[results lastObject] isKindOfClass:[NSDictionary class]]) {
        //sort results array
        NSSortDescriptor *sortDescr = [[NSSortDescriptor alloc] initWithKey:serverDataKey ascending:YES];
        NSArray *sortDescriptorsArr = [NSArray arrayWithObject:sortDescr];
        sortedResults = [results sortedArrayUsingDescriptors:sortDescriptorsArr];
    }

    
    for (int i = 0; i < batchesNumber; i++){
        
        subResults = [sortedResults subarrayWithRange:NSMakeRange(i * batchSize,MIN(batchSize, count - i * batchSize))];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:primaryKey ascending:YES];
        subResults = [subResults sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        //This will tell our database to fetch only objects whos id's are in our subresults array
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K IN %@)",primaryKey,[subResults valueForKey:serverDataKey]];
        
        //Sort ascending our fetched data
        NSArray *sortDescriptors = @[sortDescriptor];
        matchesFromDB = nil;
        //Make the fetch request
        if (([[subResults valueForKey:serverDataKey] count] == 0) ||
            [[[subResults valueForKey:serverDataKey] lastObject] isKindOfClass:[NSNull class]]) {
            matchesFromDB = @[];
        }
        else {
            matchesFromDB = [self fetchDataWithParameterBlock:^(NSFetchRequest *requestToBeParametered) {
                requestToBeParametered.predicate = predicate;
                requestToBeParametered.sortDescriptors = sortDescriptors;
            } andTableName:tableName inObjectContext:managedObjectContext];
        }
        if (matchesFromDB.count > 0)
        {
            //Make our arrays one direction queue
            enumeratedResults = [subResults objectEnumerator];
            enumeratedMatches = [matchesFromDB objectEnumerator];
            
            id result = [enumeratedResults nextObject];
            id match = [enumeratedMatches nextObject];
            
            while (result) {
                //Check if we have a match
                //If so update else insert and empty object and fill it
                if ([[result valueForKey:serverDataKey] isEqual:[match valueForKey:primaryKey]]){
                    match = [enumeratedMatches nextObject];
                    
                } else {
                    id insertedValue = [self insertDataForTableName:tableName inObjectContext:managedObjectContext];
                    updateBlock(insertedValue,result);
                }
                
                result = [enumeratedResults nextObject];
            }
        } else //DDLog(@"Couldn't find any matches");
        {
            
            enumeratedResults = [subResults objectEnumerator];
            id result = [enumeratedResults nextObject];
            while (result) {
                
                id insertedValue = [self insertDataForTableName:tableName inObjectContext:managedObjectContext];
                updateBlock(insertedValue,result);
                result = [enumeratedResults nextObject];
            }
            
        }
    }
}

- (void)fetchAsyncNotFoundDataFromTable:(NSString *)tableName
                              inResults:(NSArray *)results
                         withPrimaryKey:(NSString *)primaryKey
                          andCompletion:(CompletionBlock)completion
{
    
    //This will tell our database to fetch only objects whos id's are not in our subresults array
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (%K IN %@)",primaryKey, results];
    
    //Sort ascending our fetched data
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:primaryKey ascending:YES]];
    //Make the fetch request
    
    [self fetchDataAsyncWithParameterBlock:^(NSFetchRequest *requestToBeParametered) {
        requestToBeParametered.predicate = predicate;
        requestToBeParametered.sortDescriptors = sortDescriptors;
        
    } andTableName:tableName andCompletion:^(BOOL success, id returnObject) {
        completion(success,returnObject);
    }];
    
}

- (NSArray*)fetchNotFoundDataFromTable:(NSString *)tableName
                              inResults:(NSArray *)results
                         withPrimaryKey:(NSString *)primaryKey
{
    
    //This will tell our database to fetch only objects whos id's are not in our subresults array
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (%K IN %@)",primaryKey, results];
    
    //Sort ascending our fetched data
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:primaryKey ascending:YES]];
    //Make the fetch request
    
    return [self fetchDataWithParameterBlock:^(NSFetchRequest *requestToBeParametered) {
        requestToBeParametered.predicate = predicate;
        requestToBeParametered.sortDescriptors = sortDescriptors;
        
    } andTableName:tableName];
    
}

- (void)save{
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    
    if (error) NSLog(@"Could not save changes to database: %@",error);
}

#pragma mark - Get a managed object context

- (NSManagedObjectContext*)getNewManagedObjectContext{
    // Create a new managed object context
    // Set its persistent store coordinator
    NSManagedObjectContext *newMoc = [[NSManagedObjectContext alloc] init];
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

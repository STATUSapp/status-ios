//
//  STCoreDataManager.h
//  Status
//
//  Created by Andrus Cosmin on 25/07/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//


#import <CoreData/CoreData.h>

//Block Defines
typedef void (^CompletionBlock)(BOOL success, id returnObject);
typedef void (^ParameterBlock)(NSFetchRequest* requestToBeParametered);

@interface STCoreDataManager : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//Methods

/**
 * Create new managed object context for temporary data
 */
- (NSManagedObjectContext*)getNewManagedObjectContext;

/**
 * Fetches data from CoreData with custom parameters
 * @param parameterBlock ... with this we can set any parameters to the NSFetchRequest instance
 * @param tableName ... the name of the desired table in the db
 */
- (NSArray*)fetchDataWithParameterBlock:(ParameterBlock)parameterBlock
                           andTableName:(NSString*)tableName;
- (void)fetchDataAsyncWithParameterBlock:(ParameterBlock)parameterBlock
                            andTableName:(NSString*)tableName
                           andCompletion:(CompletionBlock)completionBlock;

/**
 * Adds an object into the specified table
 * @param tableName ... the name of the desired table in the db
 * @returns newly inserted object
 */
- (id)insertDataForTableName:(NSString*)tableName;

- (id)insertDataForTableName:(NSString *)tableName
             inObjectContext:(NSManagedObjectContext*)managedObjectContext;

/**
 * Deletes all objects from the specified table
 * @param tableName ... the name of the desired table in the db
 */
- (void)deleteAllObjectsFromTable:(NSString *)tableName withPredicate:(NSPredicate*)predicate;

/**
 * Saves changes in the db
 */
- (void)save;

/**
 * Init and clean local database
 */
- (void)cleanLocalDataBase;

@end

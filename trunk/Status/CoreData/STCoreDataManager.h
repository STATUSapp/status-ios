//
//  SLCoreDataManager.h
//  Solum
//
//  Created by Cosmin Andrus on 10/25/13.
//  Copyright (c) 2013
//


#import <CoreData/CoreData.h>

//TODO: clean for unused methods

//Block Defines
typedef void (^CompletionBlock)(BOOL success, id returnObject);
typedef void (^UpdateBlock)(id dbObject,id updateData);
typedef void (^ParameterBlock)(NSFetchRequest* requestToBeParametered);
typedef void (^AddParameterBlock)(id returnObject, NSManagedObjectContext* managedObjectContext);

@class SLTableRelationshipManager;

@interface STCoreDataManager : NSObject{
    
//    NSDictionary *_dbRelationEntityNameDictionary;
//    NSDictionary *_dbRelationBackwardRelationDictionary;
    SLTableRelationshipManager* _tableRelationshipsManager;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//Methods

+ (STCoreDataManager*)sharedManager;

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
 * Adds async an object into the specified table 
 * @param dataArray ... the data to be added
 * @param tableName ... the name of the desired table in the db
 * @param updateBlock ...  custom code to fill the newly added object with info from dataArray
 */
- (void)insertDataAsync:(NSArray*)dataArray forTableName:(NSString*)tableName withUpdateBlock:(UpdateBlock)updateBlock andCompletion:(CompletionBlock)completionBlock;

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

/**
 * Used as an abstract method of update-ing any object from db
 * @param addBlock ... make operations with the objects after is insertion in the db
 * @param entityName ... the CoreData entity(table) that we wish to update
 * @param serverData ... the data from server in JSON format
 * @param andCompletion 
 */
- (void)synchronizeAsyncCoreDataEntity:(NSString*)entityName
                              withData:(NSDictionary*)serverData
                         andCompletion:(CompletionBlock)completion;


- (void)synchronizeCoreDataEntity:(NSString*)entityName
                         withData:(NSArray*)serverData;

/**
 * Get results from database that are not found in the passed results array object. Used to make DIFFs with server data
 * @param tableName ... the CoreData entity(table) that we wish to search
 * @param primaryKey ... unique identifier that we use to check if the data already exists in the entity
 * @param resulst ... the results array that is used for search
 */
- (void)fetchAsyncNotFoundDataFromTable:(NSString *)tableName
                             inResults:(NSArray *)results
                        withPrimaryKey:(NSString *)primaryKey
                     andCompletion:(CompletionBlock)completion;

- (NSArray*)fetchNotFoundDataFromTable:(NSString *)tableName
                         inResults:(NSArray *)results
                    withPrimaryKey:(NSString *)primaryKey;


@end

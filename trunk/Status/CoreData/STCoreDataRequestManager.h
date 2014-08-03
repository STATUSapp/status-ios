//
//  SLCoreDataRequestManager.h
//

//TODO: clean for unused methods


#import <CoreData/CoreData.h>

extern NSString *const kCDRChangedObject;
extern NSString *const kCDRChangeType;

@protocol SLCoreDataRequestManagerDelegate;

@interface STCoreDataRequestManager : NSObject <NSFetchedResultsControllerDelegate>

@property (nonatomic,weak) UITableView *tableView;
@property (nonatomic,assign) BOOL shouldNotifyInsertDelete;

@property (nonatomic,strong,readonly) NSString *entityName;
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic,strong) NSArray *sortDescriptors;
@property (nonatomic,strong) NSPredicate *predicate;
@property (nonatomic,strong) NSMutableArray *delegatesArray;
@property (nonatomic,strong) NSManagedObjectContext *managedObjContext;

//Methods
- (NSFetchedResultsController*)fetchRequestWithEntityName:(NSString*)entityName
                                   withSectionNameKeyPath:(NSString*) sectionNameKeyPath
                                         ofFetchBatchSize:(int) batchSize
                                             forTableView:(UITableView*)tableView;

- (NSFetchedResultsController*)fetchRequestWithEntityName:(NSString*)entityName
                                   withSectionNameKeyPath:(NSString*) sectionNameKeyPath
                                         ofFetchBatchSize:(int) batchSize
                                   inManagedObjectContext:(NSManagedObjectContext*)moc
                                             forTableView:(UITableView*)tableView;

- (void)performFetch;

//Accessors
- (NSArray*)sections;
- (NSUInteger)numberOfSections;
- (id)objectAtIndexPath:(NSIndexPath*)indexPath;
- (NSUInteger)numberOfObjectsInSection:(NSInteger) section;
- (id)objectsInSection:(NSInteger)section;
- (id)allObjects;
- (NSIndexPath*)indexPathForObject:(id)object;

//delegates
- (void)addToDelegatesArray:(id<SLCoreDataRequestManagerDelegate>)delegate;
- (void)removeFromDelegatesArray:(id<SLCoreDataRequestManagerDelegate>)delegate;

@end

@protocol SLCoreDataRequestManagerDelegate <NSObject>

@optional
- (void)controllerContentChanged:(NSArray*)objects forCDReqManager:(STCoreDataRequestManager*)cdReqManager;
- (void)controllerContentChanged:(NSArray*)objects;
- (void)controllerAddedObject:(id)object atIndexPath:(NSIndexPath*)indexPath;
- (void)controllerRemovedObject:(id)object atIndexPath:(NSIndexPath*)indexPath;
@end

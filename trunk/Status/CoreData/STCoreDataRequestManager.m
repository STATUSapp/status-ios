//
//  SLCoreDataRequestManager.m
//

#import "STCoreDataRequestManager.h"
#import "STCoreDataManager.h"

NSString *const kCDRChangedObject = @"object";
NSString *const kCDRChangeType = @"change_type";

@implementation STCoreDataRequestManager

#pragma mark - Query Methods

-(id)init {
    self = [super init];
    if (self) {
        _delegatesArray = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}

- (NSFetchedResultsController*)fetchRequestWithEntityName:(NSString*)entityName
                                   withSectionNameKeyPath:(NSString*)sectionNameKeyPath
                                         ofFetchBatchSize:(int) batchSize
                                             forTableView:(UITableView*)tableView{
    
    return [self fetchRequestWithEntityName:entityName
                     withSectionNameKeyPath:sectionNameKeyPath
                           ofFetchBatchSize:batchSize
                     inManagedObjectContext:[[STCoreDataManager sharedManager] managedObjectContext]
                               forTableView:tableView];
}

- (NSFetchedResultsController*)fetchRequestWithEntityName:(NSString*)entityName
                                   withSectionNameKeyPath:(NSString*) sectionNameKeyPath
                                         ofFetchBatchSize:(int) batchSize
                                   inManagedObjectContext:(NSManagedObjectContext*)moc
                                             forTableView:(UITableView*)tableView{
    
    _managedObjContext = moc?moc:[[STCoreDataManager sharedManager] getNewManagedObjectContext];
    
    if (tableView && ![tableView isKindOfClass:[UITableView class]]) {
        NSLog(@"Error!");
    }
    _entityName = entityName;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName
                                              inManagedObjectContext:_managedObjContext];
    [fetchRequest setEntity:entity];
    if ([self.sortDescriptors count])
        [fetchRequest setSortDescriptors:self.sortDescriptors];
    
    if (batchSize>0)
        [fetchRequest setFetchBatchSize:batchSize];
    
    if (self.predicate)
        [fetchRequest setPredicate:self.predicate];
    
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest                                                                                                  managedObjectContext:_managedObjContext                                                                                                    sectionNameKeyPath:sectionNameKeyPath                                                                                                             cacheName:nil];
    _fetchedResultsController = theFetchedResultsController;
    _tableView = tableView;
    
    _fetchedResultsController.delegate = self;
    
    [self performFetch];
    
    [self announceDelegates];
    
    return _fetchedResultsController;
}

- (void)performFetch
{
    NSError *error;
	if (![_fetchedResultsController performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved fetched error %@, %@", error, [error userInfo]);
	}
}

#pragma mark - Accessors

- (NSUInteger)numberOfSections
{
    NSUInteger sections = [[_fetchedResultsController sections] count];
    
    return sections;
}

- (NSUInteger)numberOfObjectsInSection:(NSInteger) section{
    id  sectionInfo = [_fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (id)objectAtIndexPath:(NSIndexPath*)indexPath{
    return [_fetchedResultsController objectAtIndexPath:indexPath];
}

- (id)objectsInSection:(NSInteger)section{
    return [[self.fetchedResultsController.sections objectAtIndex:section] objects];
}

- (id)allObjects{
    return [self.fetchedResultsController fetchedObjects];
}

- (NSArray*)sections{
    return self.fetchedResultsController.sections;
}

#pragma mark - Delegates
- (void)addToDelegatesArray:(id<SLCoreDataRequestManagerDelegate>)delegate{
    if (!delegate) {
        return;
    }
    
    [_delegatesArray addObject: [NSValue valueWithPointer:(__bridge const void *)(delegate)]];
}
- (void)removeFromDelegatesArray:(id<SLCoreDataRequestManagerDelegate>)delegate{
    [_delegatesArray removeObject:[NSValue valueWithPointer:(__bridge const void *)(delegate)]];
    if ([_delegatesArray count] == 0) {
        _fetchedResultsController.delegate = nil;
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
    
    if (self.shouldNotifyInsertDelete){
        switch (type) {
            case NSFetchedResultsChangeInsert:
            
                for (NSValue* delegatePointer in _delegatesArray) {
                    id<SLCoreDataRequestManagerDelegate> delegate = (id<SLCoreDataRequestManagerDelegate>)[delegatePointer pointerValue];
                    if ([delegate respondsToSelector:@selector(controllerAddedObject:atIndexPath:)]) {
                        [delegate controllerAddedObject:anObject atIndexPath:indexPath];
                    }
                }

                break;
            case NSFetchedResultsChangeDelete:
                for (NSValue* delegatePointer in _delegatesArray) {
                    id<SLCoreDataRequestManagerDelegate> delegate = (id<SLCoreDataRequestManagerDelegate>)[delegatePointer pointerValue];
                    if ([delegate respondsToSelector:@selector(controllerRemovedObject:atIndexPath:)]) {
                        [delegate controllerRemovedObject:anObject atIndexPath:indexPath];
                    }
                }
                break;
            default:
                break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (_tableView) {
        [_tableView reloadData];
    }
    [self announceDelegates];
}

-(void)announceDelegates {
    for (NSValue* delegatePointer in _delegatesArray) {
        id<SLCoreDataRequestManagerDelegate> delegate = (id<SLCoreDataRequestManagerDelegate>)[delegatePointer pointerValue];
        if ([delegate respondsToSelector:@selector(controllerContentChanged:)]) {
            [delegate controllerContentChanged:[self allObjects]];
        }
        if ([delegate respondsToSelector:@selector(controllerContentChanged:forCDReqManager:)]) {
            [delegate controllerContentChanged:[self allObjects] forCDReqManager:self];
        }
    }
}

-(NSIndexPath*)indexPathForObject:(id)object {
    return [_fetchedResultsController indexPathForObject:object];
}

-(void)dealloc{
    _fetchedResultsController.delegate = nil;
    _fetchedResultsController = nil;
    _tableView = nil;
    _delegatesArray = nil;
}

@end

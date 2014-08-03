//
//  SLDataManager.m
//  Solum
//
//  Created by Cosmin Andrus on 10/16/13.
//  Copyright (c) 2013 Solum. All rights reserved.
//

//TODO: clean for unused methods


#import "STDAOEngine.h"
#import "STCoreDataManager.h"

@interface STDAOEngine() {

}
@end

@implementation STDAOEngine

static STDAOEngine *g_sharedManager = nil;

+ (STDAOEngine*)sharedManager
{
    @synchronized([STDAOEngine class]){
        if (!g_sharedManager)
            g_sharedManager = [[self alloc] init];
        
        return g_sharedManager;
    }
    return nil;
}

-(id)init{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (id)alloc
{
	NSAssert(!g_sharedManager, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}


#pragma mark - Util Methods

- (STCoreDataRequestManager*)fetchRequestManagerForEntity:(NSString*)entityName
                                           sortDescritors:(NSArray*)sortDescriptors
                                                predicate:(NSPredicate*)predicate
                                       sectionNameKeyPath:(NSString*)sectionNameKeyPath
                                                 delegate:(id<SLCoreDataRequestManagerDelegate>)rmDelegate
                                             andTableView:(UITableView*)tableView{
    
//    if (tableView) {
//        NSLog(@"aici");
//    }
    
    STCoreDataRequestManager* resultsCDRequestManager = [[STCoreDataRequestManager alloc] init];
    if (rmDelegate) {
        [resultsCDRequestManager addToDelegatesArray:rmDelegate];        
    }

    resultsCDRequestManager.sortDescriptors = sortDescriptors;
    resultsCDRequestManager.predicate = predicate;
    
    [resultsCDRequestManager fetchRequestWithEntityName:entityName
                                 withSectionNameKeyPath:sectionNameKeyPath
                                       ofFetchBatchSize:0
                                           forTableView:tableView];
    
    
    
    return resultsCDRequestManager;
    
}

/*
- (SLCoreDataRequestManager *)retrieveNotesForWorkOrderId:(NSString*)woId
                                                   ofType:(int)type
                                                tableView:(UITableView*)tableView
                               withRequestManagerDelegate:(id<SLCoreDataRequestManagerDelegate>)rmDelegate {
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kKeyCreateDate ascending:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"work_order.uuid == %@ AND type == %d", woId, type];
    
    SLCoreDataRequestManager *woCDRequestManager = [self fetchRequestManagerForEntity:kTableMessages
                                                                       sortDescritors:@[sortDescriptor]
                                                                            predicate:predicate
                                                                   sectionNameKeyPath:nil
                                                                             delegate:rmDelegate
                                                                         andTableView:tableView];
    return woCDRequestManager;
}
*/

@end

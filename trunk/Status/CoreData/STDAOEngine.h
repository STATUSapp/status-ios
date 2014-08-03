//
//  SLDataManager.h
//  Solum
//
//  Created by Cosmin Andrus on 10/16/13.
//  Copyright (c) 2013 Solum. All rights reserved.
//
//TODO: clean for unused methods


#import <Foundation/Foundation.h>
#import "STCoreDataRequestManager.h"

typedef void (^SLDAOCompletionBlock)(id returnedObject, BOOL success);
typedef NSArray* (^SLDAOInterceptBlock)(id serverObj);

@interface STDAOEngine : NSObject {
}


+ (STDAOEngine *)sharedManager;

- (STCoreDataRequestManager*)fetchRequestManagerForEntity:(NSString*)entityName
                                           sortDescritors:(NSArray*)sortDescriptors
                                                predicate:(NSPredicate*)predicate
                                       sectionNameKeyPath:(NSString*)sectionNameKeyPath
                                                 delegate:(id<SLCoreDataRequestManagerDelegate>)rmDelegate
                                             andTableView:(UITableView*)tableView;


@end


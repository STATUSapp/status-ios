//
//  STDAOEngine.h
//  Status
//
//  Created by Andrus Cosmin on 25/07/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STCoreDataRequestManager.h"

@interface STDAOEngine : NSObject
+ (STDAOEngine *)sharedManager;

- (STCoreDataRequestManager*)fetchRequestManagerForEntity:(NSString*)entityName
                                           sortDescritors:(NSArray*)sortDescriptors
                                                predicate:(NSPredicate*)predicate
                                       sectionNameKeyPath:(NSString*)sectionNameKeyPath
                                                 delegate:(id<SLCoreDataRequestManagerDelegate>)rmDelegate
                                             andTableView:(UITableView*)tableView;


@end


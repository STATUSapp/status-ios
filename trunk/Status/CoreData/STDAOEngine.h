//
//  SLDataManager.h
//  Solum
//
//  Created by Cosmin Andrus on 10/16/13.
//  Copyright (c) 2013 Solum. All rights reserved.
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


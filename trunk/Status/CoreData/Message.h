//
//  Message.h
//  Status
//
//  Created by Cosmin Andrus on 09/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Message : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * received;
@property (nonatomic, retain) NSString * roomID;
@property (nonatomic, retain) NSNumber * seen;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSString * sectionDate;

@end

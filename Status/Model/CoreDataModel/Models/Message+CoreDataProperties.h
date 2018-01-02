//
//  Message+CoreDataProperties.h
//  Status
//
//  Created by Cosmin Andrus on 31/12/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//
//

#import "Message+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Message (CoreDataProperties)

+ (NSFetchRequest<Message *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *date;
@property (nullable, nonatomic, copy) NSString *message;
@property (nullable, nonatomic, copy) NSNumber *received;
@property (nullable, nonatomic, copy) NSString *roomID;
@property (nullable, nonatomic, copy) NSString *sectionDate;
@property (nullable, nonatomic, copy) NSNumber *seen;
@property (nullable, nonatomic, copy) NSString *userId;
@property (nullable, nonatomic, copy) NSString *uuid;

@end

NS_ASSUME_NONNULL_END

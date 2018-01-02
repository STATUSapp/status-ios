//
//  Brand+CoreDataProperties.h
//  Status
//
//  Created by Cosmin Andrus on 31/12/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//
//

#import "Brand+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Brand (CoreDataProperties)

+ (NSFetchRequest<Brand *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *uuid;
@property (nullable, nonatomic, copy) NSString *image_url;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *indexString;

@end

NS_ASSUME_NONNULL_END

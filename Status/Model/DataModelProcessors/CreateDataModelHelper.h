//
//  CreateDataModelHelper.h
//  Status
//
//  Created by Silviu Burlacu on 07/06/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CreateDataModelHelper : NSObject

+ (id)validObjectFromDict:(NSDictionary *)dict forKey:(NSString *)key;

@end

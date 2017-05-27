//
//  STImageCacheObj.h
//  Status
//
//  Created by Andrus Cosmin on 17/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STBaseObj;

@interface STImageCacheObj : NSObject

@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSNumber *flowType;

+ (STImageCacheObj *)imageCacheObjFromObj:(STBaseObj *)obj;

@end

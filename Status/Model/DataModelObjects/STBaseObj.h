//
//  STBaseObj.h
//  Status
//
//  Created by Cosmin Adelin Andrus on 17/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CreateDataModelHelper.h"

extern NSString * const kObjectUuidForLoading;

@interface STBaseObj : NSObject

@property(nonatomic, strong) NSDictionary *infoDict;
@property(nonatomic, strong) NSString *uuid;
@property(nonatomic, strong) NSString *appVersion;

@property (nonatomic, assign) BOOL mainImageDownloaded;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, strong) NSString * mainImageUrl;

+ (instancetype)mockObjectLoading;
- (BOOL) isLoadingObject;

@end

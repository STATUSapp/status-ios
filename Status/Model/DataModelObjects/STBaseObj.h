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
extern NSString * const kObjectUuidForNothingToDisplay;
extern NSString * const kObjectUuidForTheEnd;

@interface STBaseObj : NSObject

@property(nonatomic, strong) NSDictionary *infoDict;
@property(nonatomic, strong) NSString *uuid;
@property(nonatomic, strong) NSString *appVersion;

@property (nonatomic, assign) BOOL mainImageDownloaded;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, strong) NSString * mainImageUrl;

+ (instancetype)mockObjectLoading;
+ (instancetype)mockObjNothingToDisplay;
+ (instancetype)mockObjTheEnd;

- (BOOL) isLoadingObject;
- (BOOL) isTheEndObject;
- (BOOL) isNothingToDisplayObj;
@end

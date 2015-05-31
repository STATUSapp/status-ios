//
//  STBaseObj.h
//  Status
//
//  Created by Cosmin Adelin Andrus on 17/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STBaseObj : NSObject
//TODO: add here all common properties or methods
@property(nonatomic, strong) NSDictionary *infoDict;
@property(nonatomic, strong) NSString *uuid;
@property(nonatomic, strong) NSString *appVersion;
@end

//
//  STFlowTemplate.h
//  Status
//
//  Created by Cosmin Adelin Andrus on 27/07/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STFlowTemplate : NSObject
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *url;

+(instancetype)flowTemplateFromDict:(NSDictionary *)dict;
-(NSString *)displayedName;
@end

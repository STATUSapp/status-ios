//
//  STFlowTemplate.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 27/07/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STFlowTemplate.h"

@implementation STFlowTemplate
+(instancetype)flowTemplateFromDict:(NSDictionary *)dict{
    STFlowTemplate * flowtemplate = [STFlowTemplate new];
    [flowtemplate setupWithDict:dict];
    
    return flowtemplate;
}

- (void)setupWithDict:(NSDictionary *)dict {
    _type = dict[@"type"];
    _url = dict[@"url"];
}

-(NSString *)displayedName{
    NSString *name = @"";
    if([_type isEqualToString:@"home"]){
        name = @"Home";
    }
    else if([_type isEqualToString:@"popular"]){
        name = @"Popular";
    }
    else if([_type isEqualToString:@"nearby"]){
        name = @"Nearby";
    }
    else if([_type isEqualToString:@"recent"]){
        name = @"Recent";
    }
    else if ([_type isEqualToString:@"other"]){
        name = @"Other";
    }
    return name;
}
@end

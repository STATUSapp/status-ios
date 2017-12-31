//
//  STBrandObj.m
//  Status
//
//  Created by Cosmin Andrus on 12/02/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STBrandObj.h"

@interface STBrandObj ()

@property (nonatomic, strong, readwrite) NSString *brandName;

@end

@implementation STBrandObj

+ (STBrandObj *)brandObjFromDict:(NSDictionary *)dict{
    STBrandObj *brandObj = [STBrandObj new];
    brandObj.uuid = [dict[@"id"] stringValue];
    brandObj.mainImageUrl = [dict[@"image_url"] stringByReplacingHttpWithHttps];
    brandObj.brandName = [dict[@"name"] capitalizedString];
    
    return brandObj;
}
@end

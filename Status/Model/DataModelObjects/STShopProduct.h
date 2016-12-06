//
//  STShopProducts.h
//  Status
//
//  Created by Cosmin Andrus on 24/10/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STBaseObj.h"

@interface STShopProduct : STBaseObj

@property (nonatomic, strong) NSString *productUrl;

+ (instancetype)shopProductWithDict:(NSDictionary *)postDict;

@end

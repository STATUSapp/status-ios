//
//  STShopProducts.h
//  Status
//
//  Created by Cosmin Andrus on 24/10/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STProductBase.h"

@interface STShopProduct : STProductBase

//this will exists only for client-added products
@property (nonatomic, strong) UIImage *localImage;

+ (instancetype)shopProductWithDict:(NSDictionary *)postDict;


@end

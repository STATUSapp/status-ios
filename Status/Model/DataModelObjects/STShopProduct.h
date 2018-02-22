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
@property (nonatomic, strong) NSString *brandName;
@property (nonatomic, strong) NSString *productName;
@property (nonatomic, strong) NSNumber *productPrice;

//this will exists only for client-added products
@property (nonatomic, strong) UIImage *localImage;

+ (instancetype)shopProductWithDict:(NSDictionary *)postDict;

-(NSString *)productPriceString;

@end

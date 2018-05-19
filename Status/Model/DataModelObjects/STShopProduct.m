//
//  STShopProducts.m
//  Status
//
//  Created by Cosmin Andrus on 24/10/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

/*
 
 {
 image = "http://d22t200r9sgmit.cloudfront.net/img/a.bc";
 link = "http://www.emag.ro";
 }
 
 */

#import "STShopProduct.h"

@implementation STShopProduct
+ (instancetype)shopProductWithDict:(NSDictionary *)postDict {
    STShopProduct * product = [STShopProduct new];
    product.infoDict = postDict;
    [product setup];
    
    return product;
}

-(void)setup{
    [super setup];
    self.productType = STProductTypeShop;
    
    //TODO: AUTO - parse proper data from BE
    self.brandName = @"ASOS";
    self.productName = @"Skinny Buffalo Check";
    self.productPrice = @(149.99);
    self.productPriceCurrency = @"$";

}

@end

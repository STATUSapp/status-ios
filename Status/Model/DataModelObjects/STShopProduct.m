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
#import "STImageCacheController.h"

@implementation STShopProduct
+ (instancetype)shopProductWithDict:(NSDictionary *)postDict {
    STShopProduct * product = [STShopProduct new];
    product.infoDict = postDict;
    [product setup];
    
    return product;
}

-(void)setup{
    
    self.productUrl = [CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"link"];
    //super properties
    self.mainImageUrl = [CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"image"];
    self.mainImageDownloaded = [STImageCacheController imageDownloadedForUrl:self.mainImageUrl];
    self.imageSize = CGSizeZero;
    
}

@end

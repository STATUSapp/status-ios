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
    
    self.uuid = [[CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"id"] stringValue];
    self.productUrl = [CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"link"];
    //super properties
    self.mainImageUrl = [[CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"image_url"] stringByReplacingHttpWithHttps];
    if (!self.mainImageUrl) {
        self.mainImageUrl = [[CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"image"] stringByReplacingHttpWithHttps];
    }
    __weak STShopProduct *weakSelf = self;
    [STImageCacheController imageDownloadedForUrl:self.mainImageUrl completion:^(BOOL cached) {
        __strong STShopProduct *strongSelf = weakSelf;
        strongSelf.mainImageDownloaded = cached;
    }];
    self.imageSize = CGSizeZero;
 
    //TODO: AUTO - parse proper data from BE
    self.brandName = @"ASOS";
    self.productName = @"Skinny Buffalo Check";
    self.productPrice = @(149.99);
}

-(BOOL)isEqual:(STShopProduct *)object{
    return [self.uuid isEqualToString:object.uuid] ||
    [self.mainImageUrl isEqualToString:object.mainImageUrl];
}

-(NSString *)productPriceString{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
    numberFormatter.locale = [NSLocale currentLocale];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.usesGroupingSeparator = YES;
    NSString *text = [NSString stringWithFormat:@"%@ lei", [numberFormatter stringFromNumber:self.productPrice]];
    return text;
}

@end

//
//  STProductBase.m
//  Status
//
//  Created by Cosmin Andrus on 17/05/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STProductBase.h"

@implementation STProductBase

-(void)setup{
    self.uuid = [[CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"id"] stringValue];
    self.productUrl = [CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"link"];
    //super properties
    self.mainImageUrl = [[CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"image_url"] stringByReplacingHttpWithHttps];
    if (!self.mainImageUrl) {
        self.mainImageUrl = [[CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"image"] stringByReplacingHttpWithHttps];
    }
    CGFloat imageHeight = [[CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"product_image_height"] doubleValue];
    CGFloat imageWidth = [[CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"product_image_width"] doubleValue];
    CGFloat imageRatio = [[CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"product_image_ratio"] doubleValue];
    [self saveDimentionsWithImageHeight:imageHeight
                             imageRatio:imageRatio
                             imageWidth:imageWidth];
    self.brandName = [CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"brand"];
    self.productName = [CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"name"];
    NSString *priceAsString = [CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"price"];
    if (priceAsString.length == 0) {
        self.productPrice = nil;
    }else{
        self.productPrice = @([priceAsString integerValue]);
    }
    self.productPriceCurrency = [CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"currency"];

}

-(NSString *)productPriceString{
    if (!self.productPrice) {
        return @"";
    }
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
    numberFormatter.locale = [NSLocale currentLocale];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.usesGroupingSeparator = YES;
    NSString *text = [NSString stringWithFormat:@"%@ %@", [numberFormatter stringFromNumber:self.productPrice], self.productPriceCurrency];
    return text;
}

-(BOOL)isEqual:(STProductBase *)object{
    return [self.uuid isEqualToString:object.uuid] ||
    [self.mainImageUrl isEqualToString:object.mainImageUrl];
}

@end

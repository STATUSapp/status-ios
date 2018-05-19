//
//  STProductBase.m
//  Status
//
//  Created by Cosmin Andrus on 17/05/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STProductBase.h"
#import "STImageCacheController.h"

@implementation STProductBase

-(void)setup{
    self.uuid = [[CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"id"] stringValue];
    self.productUrl = [CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"link"];
    //super properties
    self.mainImageUrl = [[CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"image_url"] stringByReplacingHttpWithHttps];
    if (!self.mainImageUrl) {
        self.mainImageUrl = [[CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"image"] stringByReplacingHttpWithHttps];
    }
    __weak STProductBase *weakSelf = self;
    [STImageCacheController imageDownloadedForUrl:self.mainImageUrl completion:^(BOOL cached) {
        __strong STProductBase *strongSelf = weakSelf;
        strongSelf.mainImageDownloaded = cached;
    }];
    self.imageSize = CGSizeZero;
}

-(NSString *)productPriceString{
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

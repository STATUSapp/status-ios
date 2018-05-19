//
//  STSuggestedProduct.m
//  Status
//
//  Created by Cosmin Andrus on 17/05/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STSuggestedProduct.h"

@implementation STSuggestedProduct
+ (instancetype)suggestedProductWithDict:(NSDictionary *)postDict {
    STSuggestedProduct * product = [STSuggestedProduct new];
    product.infoDict = postDict;
    [product setup];
    
    return product;
}

-(void)setup{
    [super setup];
    self.productType = STProductTypeSuggested;
    self.brandName = [CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"brand"];
    self.productName = [CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"name"];
    self.productPrice = @([[CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"price"] integerValue]);
    self.productPriceCurrency = [CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"currency"];
    
}

@end

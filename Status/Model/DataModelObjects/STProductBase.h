//
//  STProductBase.h
//  Status
//
//  Created by Cosmin Andrus on 17/05/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STBaseObj.h"
typedef NS_ENUM(NSUInteger, STProductType) {
    STProductTypeUndefined = 0,
    STProductTypeShop,
    STProductTypeSuggested,
};
@interface STProductBase : STBaseObj

@property (nonatomic, strong) NSString *productUrl;
@property (nonatomic, strong) NSString *brandName;
@property (nonatomic, strong) NSString *productName;
@property (nonatomic, strong) NSNumber *productPrice;
@property (nonatomic, strong) NSString *productPriceCurrency;
@property (nonatomic, assign) STProductType productType;

-(void)setup;

-(NSString *)productPriceString;
-(BOOL)isEqual:(STProductBase *)object;

@end

//
//  STDetailedShopProductCell.m
//  Status
//
//  Created by Cosmin Andrus on 13/02/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STDetailedShopProductCell.h"
#import "STShopProduct.h"
#import "STSuggestedProduct.h"

CGFloat const kBottomViewDefaultHeight = 65.f;

@interface STDetailedShopProductCell ()
@property (weak, nonatomic) IBOutlet UILabel *productBrandNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewSimilarButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end

@implementation STDetailedShopProductCell
+ (CGSize)cellSize{
    CGSize size = [super cellSize];
    size.height = size.height + kBottomViewDefaultHeight;
    return size;
}

- (void)configureWithShopProduct:(STShopProduct *)shopProduct{
    [super configureWithShopProduct:shopProduct];
    self.productBrandNameLabel.text = shopProduct.brandName;
    self.productNameLabel.text = shopProduct.productName;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
    numberFormatter.locale = [NSLocale currentLocale];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.usesGroupingSeparator = YES;
    self.productPriceLabel.text = [shopProduct productPriceString];
}

- (void)configureWithSuggestedProduct:(STSuggestedProduct *)suggestedProduct{
    [super configureWithSuggestedProduct:suggestedProduct];
    self.productBrandNameLabel.text = suggestedProduct.brandName;
    self.productNameLabel.text = suggestedProduct.productName;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
    numberFormatter.locale = [NSLocale currentLocale];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.usesGroupingSeparator = YES;
    self.productPriceLabel.text = [suggestedProduct productPriceString];
}


-(void)setTag:(NSInteger)tag{
    _deleteButton.tag = _viewSimilarButton.tag = tag;
}
@end

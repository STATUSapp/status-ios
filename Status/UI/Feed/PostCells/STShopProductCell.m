//
//  STShopProductCell.m
//  Status
//
//  Created by Cosmin Andrus on 25/11/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STShopProductCell.h"
#import "STShopProduct.h"
#import "UIImageView+WebCache.h"
#import "STSuggestedProduct.h"

@interface STShopProductCell ()
@property (weak, nonatomic) IBOutlet UIImageView *productImage;

@end

@implementation STShopProductCell

+ (CGSize)cellSize{
    //this is a dinamic computation
    CGSize size = [UIScreen mainScreen].bounds.size;
    if (IS_IPHONE_6_OR_MORE) {
        size = CGSizeMake(375.f, 667.f);
    }

    //TODO: CA - replace this magic numbers
    CGFloat height = roundf(size.height * 0.23);
    CGFloat width = roundf(height * 0.75);
    return CGSizeMake(width, height);
}

- (void)configureWithShopProduct:(STShopProduct *)shopProduct{
    if (shopProduct.localImage) {
        _productImage.image = shopProduct.localImage;
    }
    else{
        [_productImage sd_setImageWithURL:[NSURL URLWithString:shopProduct.mainImageUrl]];
    }
}

- (void)configureWithSuggestedProduct:(STSuggestedProduct *)suggestedProduct{
    [_productImage sd_setImageWithURL:[NSURL URLWithString:suggestedProduct.mainImageUrl]];
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [_productImage.layer setBorderColor:[[UIColor colorWithRed:225.f/255.f
                                                        green:228.f/255.f
                                                         blue:236.f/255.f
                                                         alpha:1.f] CGColor]];
    [_productImage.layer setBorderWidth:1.f];
    [_productImage.layer setCornerRadius:2.f];
    [_productImage.layer setMasksToBounds:YES];
    
}
@end

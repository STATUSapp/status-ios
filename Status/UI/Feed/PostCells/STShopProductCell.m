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

@interface STShopProductCell ()
@property (weak, nonatomic) IBOutlet UIImageView *productImage;

@end

@implementation STShopProductCell

+ (CGSize)cellSize{
    CGSize size = [UIScreen mainScreen].bounds.size;
    
    //TODO: CA - replace this magic numbers
    CGFloat height = roundf(size.height * 0.23);
    CGFloat width = roundf(height * 0.75);
    
    return CGSizeMake(width, height);
}

- (void)configureWithShopProduct:(STShopProduct *)shopProduct{
    [_productImage sd_setImageWithURL:[NSURL URLWithString:shopProduct.mainImageUrl]];
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

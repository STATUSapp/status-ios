//
//  STTagProductCell.m
//  Status
//
//  Created by Cosmin Andrus on 05/05/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STTagProductCell.h"
#import "STShopProduct.h"

@interface STTagProductCell ()
@property (weak, nonatomic) IBOutlet UILabel *brandNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productPrice;

@end

@implementation STTagProductCell

-(void)awakeFromNib{
    [super awakeFromNib];
    _loadingView.tintColor = [UIColor blackColor];
    _loadingView.type = DGActivityIndicatorAnimationTypeBallClipRotate;
    [_loadingView startAnimating];
}

-(void)setSelected:(BOOL)selected{
    
    if (selected == YES) {
//        self.layer.masksToBounds = NO;
        UIColor *orangeColor = [UIColor colorWithRed:250.f/255.f
                                               green:65.f/255.f
                                                blue:7.f/255.f
                                               alpha:1.f];
        self.layer.borderColor = orangeColor.CGColor;
        self.layer.borderWidth = 2.0f;
        self.layer.contentsScale = [UIScreen mainScreen].scale;
        //    cell.layer.shadowOpacity = 0.75f;
        //    cell.layer.shadowRadius = 5.0f;
        //    cell.layer.shadowOffset = CGSizeZero;
        //    cell.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.bounds].CGPath;
        
    }
    else
    {
        self.layer.masksToBounds = YES;
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.borderWidth = 0.0f;
    }
    
}

-(void)configureWithProduct:(STShopProduct *)product{
    _brandNameLabel.text = product.brandName;
    _productNameLabel.text = product.productName;
    _productPrice.text = [product productPriceString];
}

@end

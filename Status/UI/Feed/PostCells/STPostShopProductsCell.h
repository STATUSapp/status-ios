//
//  STPostShopProductsCell.h
//  Status
//
//  Created by Cosmin Andrus on 25/11/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STShopProduct;

@interface STPostShopProductsCell : UICollectionViewCell

- (void)configureWithProducts:(NSArray <STShopProduct *> *)products;
- (void)setCollectionViewDelegate:(id<UICollectionViewDelegate,UICollectionViewDataSource>)delegate;
+ (CGSize)cellSize;

@end

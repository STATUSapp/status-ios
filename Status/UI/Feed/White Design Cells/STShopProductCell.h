//
//  STShopProductCell.h
//  Status
//
//  Created by Cosmin Andrus on 25/11/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STShopProduct;

@interface STShopProductCell : UICollectionViewCell

+ (CGSize)cellSize;
- (void)configureWithShopProduct:(STShopProduct *)shopProduct;

@end

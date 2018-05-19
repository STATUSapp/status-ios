//
//  STShopProductCell.h
//  Status
//
//  Created by Cosmin Andrus on 25/11/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STShopProduct;
@class STSuggestedProduct;

@interface STShopProductCell : UICollectionViewCell

+ (CGSize)cellSize;
- (void)configureWithShopProduct:(STShopProduct *)shopProduct;
- (void)configureWithSuggestedProduct:(STSuggestedProduct *)suggestedProduct;

@end

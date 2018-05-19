//
//  STDetailedShopProductCell.h
//  Status
//
//  Created by Cosmin Andrus on 13/02/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STShopProductCell.h"

@interface STDetailedShopProductCell : STShopProductCell

+ (CGSize)cellSize;
- (void)configureWithShopProduct:(STShopProduct *)shopProduct;
- (void)configureWithSuggestedProduct:(STSuggestedProduct *)suggestedProduct;
- (void)setTag:(NSInteger)tag;
@end

//
//  STTagManualProductCell.h
//  Status
//
//  Created by Cosmin Andrus on 07/05/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STShopProduct;

@interface STTagManualProductCell : UICollectionViewCell

-(void)configureCellWithproduct:(STShopProduct *)product
                       andIndex:(NSInteger)index;
-(void)setTextViewWithString:(NSString *)text;

+(CGFloat)cellHeight;
@end

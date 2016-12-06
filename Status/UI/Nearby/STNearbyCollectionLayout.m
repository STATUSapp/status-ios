//
//  STNearbyCollectionLayout.m
//  Status
//
//  Created by Cosmin Andrus on 01/12/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STNearbyCollectionLayout.h"

@interface STNearbyCollectionLayout () {
    NSMutableArray <UICollectionViewLayoutAttributes *>* cache;
    
    CGFloat contentHeight;
    CGFloat contentWidth;
}

@end

@implementation STNearbyCollectionLayout

- (void)setInitialValues{
    cache = [NSMutableArray new];
    contentHeight = 0.f;
    UIEdgeInsets insets = self.collectionView.contentInset;
    contentWidth = CGRectGetWidth(self.collectionView.bounds) -
    (insets.right + insets.left);

}

-(void)prepareLayout{
    if (_newDataAvailable == YES) {
        [self setInitialValues];
        CGFloat columnWidth = contentWidth / (1.f *_numberOfColumns);
        NSMutableArray *xOffset = [NSMutableArray new];
        for (NSInteger column = 0; column < _numberOfColumns; column ++) {
            [xOffset addObject:@((1.f * column) * columnWidth)];
        }
        
        NSInteger column = 0;
        NSMutableArray *yOffset = [NSMutableArray new];
        for (NSInteger i = 0; i< _numberOfColumns; i++) {
            [yOffset addObject:@(0)];
        }
        
        for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:0]; item ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item
                                                         inSection:0];
            
//            CGFloat width = columnWidth - 2 * _cellPadding;
            CGSize itemSize = [_delegate sizeForItemAtIndexPath:indexPath];
            CGFloat height = _cellPadding + itemSize.height + _cellPadding;
            CGRect frame = CGRectMake([xOffset[column] doubleValue], [yOffset[column] doubleValue], columnWidth, height);
            CGRect insetFrame = CGRectInset(frame, _cellPadding, _cellPadding);
            
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attributes.frame = insetFrame;
            [cache addObject:attributes];
            
            contentHeight = MAX(contentHeight, CGRectGetMaxY(frame));
            [yOffset setObject:@([yOffset[column] doubleValue] + height) atIndexedSubscript:column];
            column = (column >= _numberOfColumns - 1)?0:++column;
            
            
        }
        _newDataAvailable = NO;
    }
}

-(CGSize)collectionViewContentSize{
    return CGSizeMake(contentWidth, contentHeight);
}

-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSMutableArray <UICollectionViewLayoutAttributes *> *layoutAttributes = [NSMutableArray new];
    for (UICollectionViewLayoutAttributes *attributes in cache) {
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            [layoutAttributes addObject:attributes];
        }
    }
    
    return layoutAttributes;
}
@end

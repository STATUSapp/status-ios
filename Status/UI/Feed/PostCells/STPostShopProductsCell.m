//
//  STPostShopProductsCell.m
//  Status
//
//  Created by Cosmin Andrus on 25/11/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STPostShopProductsCell.h"
#import "STShopProduct.h"
#import "STShopProductCell.h"

@interface STPostShopProductsCell ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

{
    NSArray <STShopProduct *> *_products;
}
@property (weak, nonatomic) IBOutlet UICollectionView *produsctsCollection;

@end

@implementation STPostShopProductsCell

- (void)configureWithProducts:(NSArray <STShopProduct *> *)products{
    _products = products;
    [self.produsctsCollection.collectionViewLayout invalidateLayout];
    [self.produsctsCollection reloadData];
    [self.produsctsCollection layoutIfNeeded];
}

+ (CGSize)cellSize{
    CGSize screenSize = [UIScreen mainScreen].applicationFrame.size;
    CGSize size = [STShopProductCell cellSize];
    size.height = roundf(size.height + 32.f);
    size.width = roundf(screenSize.width);
    return size;
}

#pragma mark - UICollectionViewDelegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_products count];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return [STShopProductCell cellSize];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    STShopProduct *product = [_products objectAtIndex:indexPath.row];
    NSURL *url = [NSURL URLWithString:[product.productUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = @"STShopProductCell";
    STShopProductCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    STShopProduct *product = [_products objectAtIndex:indexPath.row];
    [cell configureWithShopProduct:product];
    
    return cell;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        identifier = @"STProductsHeader";
    }
    else
        identifier = @"STProductsFooter";
    
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:identifier forIndexPath:indexPath];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    CGSize cellSize = [STShopProductCell cellSize];
    cellSize.width = 16.f;
    
    return cellSize;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGSize cellSize = [STShopProductCell cellSize];
    cellSize.width = 16.f;
    
    return cellSize;

}
@end

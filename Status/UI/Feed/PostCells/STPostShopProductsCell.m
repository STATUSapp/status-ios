//
//  STPostShopProductsCell.m
//  Status
//
//  Created by Cosmin Andrus on 25/11/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STPostShopProductsCell.h"
#import "STShopProduct.h"
#import "STDetailedShopProductCell.h"

@interface STPostShopProductsCell ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

{
    NSArray <STShopProduct *> *_products;
}
@property (weak, nonatomic) IBOutlet UICollectionView *produsctsCollection;

@end

@implementation STPostShopProductsCell

-(void)prepareForReuse{
    [super prepareForReuse];

}

-(void)awakeFromNib{
    [super awakeFromNib];
}

-(CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [STShopProductCell cellSize];
}

- (void)configureWithProducts:(NSArray <STShopProduct *> *)products{
    _products = products;
    [self setCollectionViewDelegate:self];
//    NSMutableArray <NSIndexPath *> *indexPaths = [NSMutableArray new];
//    for (NSInteger i = 0; i< _products.count; i++) {
//        [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
//    }
    NSLog(@"Reload on Products Cell");
    [self.produsctsCollection reloadData];
    [self.produsctsCollection.collectionViewLayout invalidateLayout];
//    [self.produsctsCollection layoutSubviews];

}

- (void)setCollectionViewDelegate:(id<UICollectionViewDelegate,UICollectionViewDataSource>)delegate{
    [self.produsctsCollection setDelegate:delegate];
    [self.produsctsCollection setDataSource:delegate];
}

+ (CGSize)cellSize{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGSize size = [STDetailedShopProductCell cellSize];
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
    
    return [STDetailedShopProductCell cellSize];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    STShopProduct *product = [_products objectAtIndex:indexPath.row];
    NSURL *url = [NSURL URLWithString:product.productUrl];
    if (!url) {
        url = [NSURL URLWithString:[product.productUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        
    }
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = @"STDetailedShopProductCell";
    STDetailedShopProductCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
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

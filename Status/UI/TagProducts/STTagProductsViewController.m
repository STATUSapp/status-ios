//
//  STTagProductsViewController.m
//  Status
//
//  Created by Cosmin Andrus on 05/05/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STTagProductsViewController.h"
#import "STTagProductCell.h"
#import "STShopProduct.h"
#import "UIImageView+WebCache.h"
#import "STTagProductsManager.h"

@interface STTagProductsViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<STShopProduct *> *products;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addProductHeightConstr;
@property (weak, nonatomic) IBOutlet UIButton *addProductButton;

@end

@implementation STTagProductsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateProducts:(NSArray<STShopProduct *> *)products{
    _products = products;
    [_collectionView reloadData];
}

#pragma mark - IBActions

- (IBAction)onAddProductPressed:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(addProductsAction)]) {
        [_delegate addProductsAction];
    }
}


#pragma mark - UICollectionView delegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    STTagProductCell *cell = (STTagProductCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"STTagProductCell" forIndexPath:indexPath];
    
    STShopProduct *tagProduct = _products[indexPath.item];
    
    [cell.productImage sd_setImageWithURL:[NSURL URLWithString:tagProduct.mainImageUrl] placeholderImage:nil];
    
    [cell setSelected:[[STTagProductsManager sharedInstance] isProductSelected:tagProduct]];
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_products count];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    CGFloat itemWidth = ([[UIScreen mainScreen] bounds].size.width - 18.f)/2.f;
    CGSize itemSize = CGSizeMake(itemWidth, itemWidth * 1.29);
    
    return itemSize;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    STShopProduct *tagProduct = _products[indexPath.item];
    [[STTagProductsManager sharedInstance] processProduct:tagProduct];

    [self.collectionView reloadData];
    [self updateBottomView];
    
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    if (indexPath.item == _products.count - 1) {//the last item
        if (_delegate && [_delegate respondsToSelector:@selector(productsShouldDownloadNextPage)]) {
            [_delegate productsShouldDownloadNextPage];
        }
    }
}


-(void)updateBottomView{
    NSInteger selectedProductsCount = [STTagProductsManager sharedInstance].selectedProducts.count;
    
    if (selectedProductsCount == 0) {
        _addProductHeightConstr.constant = 0;
    }
    else
    {
        _addProductHeightConstr.constant = 44.f;
        
        if (selectedProductsCount == 1) {
            [_addProductButton setTitle:NSLocalizedString(@"ADD PRODUCT", nil) forState:UIControlStateNormal];
        }
        else
        {
            [_addProductButton setTitle:NSLocalizedString(@"ADD PRODUCTS", nil) forState:UIControlStateNormal];
        }
    }
}

@end

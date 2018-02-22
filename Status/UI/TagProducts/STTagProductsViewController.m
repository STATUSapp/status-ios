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
    [self updateBottomView];
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
    __weak STTagProductCell *weakCell = cell;
    [cell.loadingView startAnimating];
    [cell.productImage sd_setImageWithURL:[NSURL URLWithString:tagProduct.mainImageUrl] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [weakCell.loadingView stopAnimating];
    }];
    
    [cell setSelected:[_delegate isProductSelected:tagProduct]];
    
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
    [_delegate selectProduct:tagProduct];

    [self.collectionView reloadData];
    [self updateBottomView];
    
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    if (indexPath.item == _products.count - 1) {//the last item
        [_delegate productsShouldDownloadNextPage];
    }
}


-(void)updateBottomView{
    NSInteger selectedProductsCount = [_delegate selectedProductCount];
    
    if (selectedProductsCount == 0) {
        _addProductHeightConstr.constant = 0;
    }else{
        _addProductHeightConstr.constant = 44.f;
        [_addProductButton setTitle:[_delegate bottomActionString] forState:UIControlStateNormal];
    }
    
    [self.view layoutIfNeeded];
}

@end

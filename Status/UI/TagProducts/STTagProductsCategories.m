//
//  STTagProductsCategories.m
//  Status
//
//  Created by Cosmin Andrus on 30/04/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STTagProductsCategories.h"

#import "STDataAccessUtils.h"
#import "STCatalogCategory.h"
#import "STCatalogParentCategory.h"

#import "STTagCategoryCell.h"

#import "UIImageView+WebCache.h"

@interface STTagProductsCategories ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *categoriesCollectionView;
@property (nonatomic, strong) NSArray<STCatalogCategory *> *categories;;

@end

@implementation STTagProductsCategories

+(STTagProductsCategories *)newController{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TagProductsScene" bundle:nil];
    STTagProductsCategories *vc = [storyboard instantiateViewControllerWithIdentifier:@"TAG_CATEGORIES_VC"];
    
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateCategories:(NSArray <STCatalogCategory *> *)categories{
    _categories = [NSArray arrayWithArray:categories];
    [_categoriesCollectionView reloadData];
}

#pragma mark - UICollectionView delegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    STTagCategoryCell *cell = (STTagCategoryCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"STTagCategoryCell" forIndexPath:indexPath];
    
    STCatalogCategory *catCategory = _categories[indexPath.item];
    
    cell.categoryName.text = catCategory.name;
    [cell.categoryImage sd_setImageWithURL:[NSURL URLWithString:catCategory.mainImageUrl] placeholderImage:nil];
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_categories count];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat itemWidth = (collectionView.frame.size.width - 6.f)/2.f;
    CGSize itemSize = CGSizeMake(itemWidth, itemWidth * 0.73);
    
    return itemSize;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (_delegate && [_delegate respondsToSelector:@selector(categoryWasSelected:)]) {
        STCatalogCategory *catCategory = _categories[indexPath.item];
        [_delegate categoryWasSelected:catCategory];
    }
}
@end

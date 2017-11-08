//
//  STTagProductsBrands.m
//  Status
//
//  Created by Cosmin Andrus on 06/05/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STTagProductsBrands.h"
#import "STTagBrandCell.h"
#import "STBrandObj.h"
#import "UIImageView+WebCache.h"
#import "STTagProductsManager.h"
#import "STTabBarViewController.h"
#import "STTagSuggestions.h"

@interface STTagProductsBrands ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<STBrandObj *>*brandArray;

@end

@implementation STTagProductsBrands

+(STTagProductsBrands *)brandsViewControllerWithDelegate:(id<STTagBrandsProtocol, STTagSuggestionsProtocol>)delegate{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"TagProductsScene" bundle:nil];
    STTagProductsBrands *vc = [storyBoard instantiateViewControllerWithIdentifier:@"TAG_BRANDS_VC"];
    vc.delegate = delegate;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(brandsWereUpdated:) name:kTagProductNotification object:nil];
    [self reloadScreen];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [(STTabBarViewController *)self.tabBarController setTabBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [(STTabBarViewController *)self.tabBarController setTabBarHidden:NO];
}

-(void)reloadScreen{
    _brandArray = [STTagProductsManager sharedInstance].brands;
    [_collectionView reloadData];
}

#pragma mark - UINotifications
- (void)brandsWereUpdated:(NSNotification *)notification{
    STTagManagerEvent event = [notification.userInfo[kTagProductUserInfoEventKey] integerValue];
    if (event == STTagManagerEventBrands) {
        [self reloadScreen];
    }
}

#pragma mark - IBActions

-(IBAction)onBackPressed:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UICollectionView delegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    STTagBrandCell *cell = (STTagBrandCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"STTagBrandCell" forIndexPath:indexPath];
    
    STBrandObj *brand = _brandArray[indexPath.item];
    
    [cell.brandImage sd_setImageWithURL:[NSURL URLWithString:brand.mainImageUrl] placeholderImage:nil];
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_brandArray count];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat itemWidth = (collectionView.frame.size.width - 6.f)/2.f;
    CGSize itemSize = CGSizeMake(itemWidth, itemWidth * 0.73);
    
    return itemSize;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    STBrandObj *brand = _brandArray[indexPath.item];
    [[STTagProductsManager sharedInstance] updateBrand:brand];
    STTagSuggestions *vc = [STTagSuggestions suggestionsVCWithScreenType:STTagSuggestionsScreenTypeDefault];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    if (indexPath.item == _brandArray.count - 1) {//the last item
        if (_delegate && [_delegate respondsToSelector:@selector(brandsShouldDownloadNextPage)]) {
            [_delegate brandsShouldDownloadNextPage];
        }
    }
}

@end

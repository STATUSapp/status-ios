//
//  STTutorialViewController.m
//  Status
//
//  Created by Cosmin Andrus on 11/02/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STTutorialViewController.h"
#import "STTutorialCell.h"
#import "STTutorialModel.h"

NSString * const kTutorialCell = @"STTutorialCell";

@interface STTutorialViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    NSArray <STTutorialModel *>*dataSource;
}
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *multipleTapToChangeBaseUrl;

@end

@implementation STTutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_skipFirstItem) {
        _multipleTapToChangeBaseUrl.enabled = NO;
    }else{
        _multipleTapToChangeBaseUrl.enabled = YES;
    }
}
-(void)viewWillLayoutSubviews{
    [self buildDatasource];
    CGRect screenRect = self.view.bounds;
    CGSize size =  CGSizeMake(screenRect.size.width, screenRect.size.height);
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    [flowLayout setItemSize:size];
    [self.collectionView setPagingEnabled:YES];
    [self.collectionView setCollectionViewLayout:flowLayout];
    [self.collectionView reloadData];
    
    [_pageControl setNumberOfPages:dataSource.count];

}

- (void)buildDatasource{
    NSMutableArray <STTutorialModel *>*tutorialObjects = [NSMutableArray new];
    
    for (NSInteger i = 0; i<STTutorialCount; i++) {
        STTutorialModel *model = [STTutorialModel new];
        model.type = i;
        NSString *title = nil;
        NSString *subtitle = nil;
        NSString *imageName = nil;
        
        switch (i) {
            case STTutorialDiscover:
            {
                title = @"DISCOVER";
                subtitle = @"You’re in control. Discover hundreds of\nready to wear outfits by browsing in our 2\nnews feeds: Popular and Recent.";
                imageName = @"tutorial_discover";
            }
                break;
            case STTutorialShopStyle:
            {
                title = @"SHOP THE STYLE";
                subtitle = @"Each time you see the shopping icon\nit means that you can shop the look.";
                imageName = @"tutorial_shop_style";
            }
                break;
            case STTutorialTagProducts:
            {
                title = @"TAG THE PRODUCTS";
                subtitle = @"Let the people know what you wear.\nChoose the products from hundreds brands\nlike Topman, Topshop, ASOS and many more.";
                imageName = @"tutorial_tag_products";
            }
                break;
            case STTutorialShareOutfit:
            {
                title = @"SHARE YOUR OUTFITS";
                subtitle = @"Be a source of inspiration for other people\nand climb the TOP in the Popular section.";
                imageName = @"tutorial_share_outfit";
            }
                break;
                
                
            default:
                break;
        }
        
        model.title = title;
        model.subtitle = subtitle;
        model.imageName = imageName;
        
        [tutorialObjects addObject:model];
    }
    
    
    if (_skipFirstItem) {
        [tutorialObjects removeObjectAtIndex:0];
    }
    
    dataSource = [NSArray arrayWithArray:tutorialObjects];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSString *)identifierForTutorialModel:(STTutorialModel *)model{    
    return kTutorialCell;
}
#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

#pragma mark - UICollectionViewDelegate
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    STTutorialModel *model = dataSource[indexPath.row];
    
    NSString *identifier = [self identifierForTutorialModel:model];
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if ([cell isKindOfClass:[STTutorialCell class]]) {
        STTutorialCell *theCell = (STTutorialCell *)cell;
        [theCell configureWithModel:model];
    }

    return cell;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return dataSource.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.view.frame.size;
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGPoint point = scrollView.contentOffset;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    NSUInteger currentIndex = point.x/screenWidth;
    [_pageControl setCurrentPage:currentIndex];
}

#pragma mark - IBAction

- (IBAction)onMultipleTap:(id)sender {
    UICollectionViewCell *cell = self.collectionView.visibleCells.firstObject;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    if (indexPath.row == STTutorialShopStyle) {
        if (_delegate && [_delegate respondsToSelector:@selector(multipleTapOnShopStyle)]) {
            [_delegate multipleTapOnShopStyle];
        }
        NSLog(@"10 times tap on Shop Style");
    }
}

@end

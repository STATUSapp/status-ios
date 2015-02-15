//
//  STTutorialViewController.m
//  Status
//
//  Created by Cosmin Andrus on 11/02/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STTutorialViewController.h"
#import "STTutorialCell.h"

NSString *const kTutorialTitleKey = @"tutorial_title";
NSString *const kTutorialSubtitleKey = @"tutorial_subtitle";

@interface STTutorialViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    NSMutableArray *dataSource;
}
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation STTutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
-(void)viewWillLayoutSubviews{
    CGRect screenRect = self.view.bounds;
    CGFloat screenWidth = screenRect.size.width;
    CGSize size =  CGSizeMake(screenWidth, screenRect.size.height-55);
    NSLog(@"Test frame: %@",NSStringFromCGRect(self.view.bounds));
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    [flowLayout setItemSize:size];
    [self.collectionView setPagingEnabled:YES];
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    dataSource =[NSMutableArray arrayWithArray:
                 @[@{},//empty for the first item
                   @{kTutorialSubtitleKey:@"Check out photos of people\n nearby. Decide whether you\n like them and find out\n who likes you back.",
                     kTutorialTitleKey:@"See and be seen"},
                   @{kTutorialSubtitleKey:@"Instantly chat\n with extraordinary\n people around you.\n",
                     kTutorialTitleKey:@"Chat with new friends"},
                   @{kTutorialSubtitleKey:@"How many likes\n do you think you'll get?\n Find out how popular\n you are!",
                     kTutorialTitleKey:@"Check your popularity"},
                   @{kTutorialSubtitleKey:@"Like 10 photos and you will\n receive 10 guaranteed views\n to your next uploaded photo.\n",
                     kTutorialTitleKey:@"Hint"}
                   ]];
    
    if (_skipFirstItem) {
        [dataSource removeObjectAtIndex:0];
    }
    [_pageControl setNumberOfPages:dataSource.count];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSString *)identifierForIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = @"STTutorialCell";
    if (!_skipFirstItem && indexPath.row == 0) {
        identifier = @"STTutorialCellStart";
    }
    
    return identifier;
}
#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

#pragma mark - UICollectionViewDelegate
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = [self identifierForIndexPath:indexPath];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if ([cell isKindOfClass:[STTutorialCell class]]) {
        STTutorialCell *theCell = (STTutorialCell *)cell;
        NSDictionary *tutorialItem = dataSource[indexPath.row];
        theCell.tutorialImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Tutorial %d", _skipFirstItem==YES?indexPath.row+1:indexPath.row]];
        theCell.titleLable.text = [tutorialItem valueForKey:kTutorialTitleKey];
        theCell.subtitleLabel.text = [tutorialItem valueForKey:kTutorialSubtitleKey];
    }
    return cell;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return dataSource.count;
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGPoint point = scrollView.contentOffset;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    NSUInteger currentIndex = point.x/screenWidth;
    [_pageControl setCurrentPage:currentIndex];
}


@end

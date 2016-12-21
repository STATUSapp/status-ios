//
//  STTutorialViewController.m
//  Status
//
//  Created by Cosmin Andrus on 11/02/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STTutorialViewController.h"
#import "STTutorialCell.h"
#import "STTutorialStartCell.h"
#import "STTutorialModel.h"

NSString * const kTutorialStartCell = @"STTutorialStartCell";
NSString * const kTutorialCell = @"STTutorialCell";

@interface STTutorialViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    NSArray <STTutorialModel *>*dataSource;
}
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation STTutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
            case STTutorialLogin:
                //nothing to do here
                break;
            case STTutorialFeed:
            {
                title = @"SHOP MY STYLE";
                subtitle = @"You can see what your\nfavorite persons are wearing.";
                imageName = @"tutorial_feed";
            }
                break;
            case STTutorialFeedShop:
            {
                title = @"SHOP MY STYLE";
                subtitle = @"Each time you see the shopping icon\nit means that you can shop the look.";
                imageName = @"tutorial_feed_shop";
            }
                break;
            case STTutorialExplore:
            {
                title = @"DISCOVER";
                subtitle = @"You’re in control. Discover people\nyou like by browsing in our 3 news feeds:\nPopular, Nearby and Recent.";
                imageName = @"tutorial_explore";
            }
                break;
            case STTutorialProfile:
            {
                title = @"CHAT AND CONNECT";
                subtitle = @"Chat with the people you like\nand follow them. That’s how the\nnew friendships are born!";
                imageName = @"tutorial_profile";
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
    if (model.type == STTutorialLogin) {
        return kTutorialStartCell;
    }
    
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
    else if ([cell isKindOfClass:[STTutorialStartCell class]]){
        [(STTutorialStartCell *)cell configureCell];
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

- (IBAction)onLoginButtonPressed:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(loginButtonPressed:)]) {
        [_delegate loginButtonPressed:sender];
    }
}


@end

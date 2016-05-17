//
//  SmallFeedCVC.m
//  Status
//
//  Created by Andrus Cosmin on 29/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "SmallFeedCVC.h"
#import "STFlowProcessor.h"
#import "STPostsPool.h"
#import "STPost.h"
#import "STUserProfile.h"
#import "SmallFeedCell.h"
#import "SmallTheEndFeedCell.h"
#import "STImageCacheController.h"
#import "STLocalNotificationService.h"
#import "STProcessorsService.h"

NSString * const kSmallFeedSelectionNotification = @"SmallFeedSelectionNotification";
CGFloat const kMarginsOffset = 8.f;

@interface SmallFeedCVC ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    CGPoint _start;
    CGPoint _end;
}
@property (nonatomic, strong) STFlowProcessor *feedProcessor;

@end

@implementation SmallFeedCVC

#pragma mark - Setters

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[_feedProcessor currentOffset] inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    STFlowProcessor *feedProcessor = [[CoreManager processorService] getProcessorWithType:_flowType];
    _feedProcessor = feedProcessor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processorLoaded) name:kNotificationObjDownloadSuccess object:_feedProcessor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postUpdated:) name:kNotificationObjUpdated object:_feedProcessor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postDeleted:) name:kNotificationObjDeleted object:_feedProcessor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postAdded:) name:kNotificationObjAdded object:_feedProcessor];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helpers

-(NSInteger)getCurrentIndex{
    NSArray *visibleInxPath = self.collectionView.indexPathsForVisibleItems;
    if (visibleInxPath.count == 0) {
        return NSNotFound;
    }
    return [[visibleInxPath objectAtIndex:0] row];
    
}

-(STPost *) getCurrentPost{
    if (self.feedProcessor.numberOfObjects == 0) {
        return nil;
    }
    STPost *post = nil;
    NSInteger index = [self getCurrentIndex];
    if (index!=NSNotFound) {
        post = [_feedProcessor objectAtIndex:index];
    }
    
    return post;
}

#pragma mark - Notifications

- (void)processorLoaded{
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

- (void)postUpdated:(NSNotification *)notif{
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadData];
    } completion:nil];
}

- (void)postAdded:(NSNotification *)notif{
    [self.collectionView reloadData];
}
- (void)postDeleted:(NSNotification *)notif{
    [self.collectionView reloadData];
}

- (void)dataShouldBeReloaded:(NSNotification *)notif{
    [_feedProcessor reloadProcessor];
    [self.collectionView reloadData];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numRows = [_feedProcessor numberOfObjects];
    return numRows;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    CGFloat viewHeight = self.view.frame.size.height;

    return CGSizeMake(kMarginsOffset, viewHeight);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGFloat viewHeight = self.view.frame.size.height;
    
    return CGSizeMake(kMarginsOffset, viewHeight);
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionReusableView * reusableview = nil ;
    
    NSString *identifier = nil;
    if ( [kind isEqualToString: UICollectionElementKindSectionHeader])
        identifier = @"EmptyHeader";
    if ( [kind isEqualToString: UICollectionElementKindSectionFooter ])
        identifier = @"EmptyFooter";
    
    reusableview = [ collectionView dequeueReusableSupplementaryViewOfKind : kind
                                                       withReuseIdentifier : identifier
                                                              forIndexPath : indexPath ] ;

    return reusableview;

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat viewHeight = self.view.frame.size.height;
    //initial is 4/3 ratio
    CGSize cellSize = CGSizeMake(viewHeight * 1.33, viewHeight);
    STPost *post = [_feedProcessor objectAtIndex:indexPath.row];
    if ([post isLoadingObject] || !post.mainImageDownloaded || CGSizeEqualToSize(post.imageSize, CGSizeZero)) {
        return cellSize;
    }
    else
    {
        CGSize imageSize = post.imageSize;
        CGFloat heightRatio = viewHeight / imageSize.height;
        CGFloat cellWidth = imageSize.width * heightRatio;
        cellSize.width = cellWidth;
    }
    
    return cellSize;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 7.f;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 7.f;
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger currentIndex = indexPath.row;
    NSLog(@"CurrentIndex: %lu", (unsigned long)currentIndex);
    [_feedProcessor processObjectAtIndex:currentIndex setSeenIfRequired:NO];

}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[SmallTheEndFeedCell class]]) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
    else if ([cell isKindOfClass:[SmallFeedCell class]]){
        [[CoreManager localNotificationService] postNotificationName:kSmallFeedSelectionNotification object:nil userInfo:@{kFlowTypeKey:@(_flowType), kOffsetKey: @(indexPath.row)}];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    STBaseObj *obj = [_feedProcessor objectAtIndex:indexPath.row];
    NSString *identifier = @"SmallFeedCell";
    
    if ([obj isTheEndObject]) {
        identifier = @"SmallTheEndFeedCell";
    }
    
    SmallFeedCell *cell = (SmallFeedCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    if ([cell isKindOfClass:[SmallFeedCell class]]) {
        if ([obj isLoadingObject]) {
            [cell setUpImage:nil];
        }
        else
        {
            __weak SmallFeedCell *weakCell = cell;
            [[CoreManager imageCacheService] loadPostImageWithName:obj.mainImageUrl withPostCompletion:^(UIImage *img) {
                [weakCell setUpImage:img];
                
            } andBlurCompletion:nil];
            
        }
    }
    
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end

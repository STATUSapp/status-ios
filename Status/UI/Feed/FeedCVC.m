//
//  FeedCVC.m
//  Status
//
//  Created by Cosmin Home on 06/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "FeedCVC.h"
#import "STPostFlowProcessor.h"
#import "STPost.h"

#import "FeedCell.h"
#import "FullCaptionFeedCell.h"
#import "STNoPhotosCell.h"
#import "FooterCell.h"

@interface FeedCVC ()

@property (nonatomic, strong) STPostFlowProcessor *feedProcessor;
@end

@implementation FeedCVC

static NSString * const normalFeedCell = @"FeedCell";
static NSString * const fullCaptionFeedCell = @"FullCaptionFeedCell";
static NSString * const loadingFeedCell = @"LoadingCell";
static NSString * const youSawAllCell = @"FeedCell";
static NSString * const noPhotosToDisplayCell = @"FooterCell";

+ (FeedCVC *)mainFeedController{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FeedScene" bundle:nil];
    UINavigationController *navController = [storyboard instantiateInitialViewController];
    FeedCVC *feedCVC = [[navController viewControllers] firstObject];
    
    STPostFlowProcessor *feedProcessor = [[STPostFlowProcessor alloc] initWithFlowType:STFlowTypeHome];
    feedCVC.feedProcessor = feedProcessor;
    
    return feedCVC;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processorLoaded) name:kNotificationPostDownloadSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageWasSavedLocally:) name:STLoadImageNotification object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notifications

- (void)processorLoaded{
    [self.collectionView reloadData];
}

-(void)imageWasSavedLocally:(NSNotification *)notif{
    dispatch_async(dispatch_get_main_queue(), ^{
        STPost *currentPost = [self getCurrentPost];
        if ([currentPost.fullPhotoUrl isEqualToString:notif.object]) {
            [self.collectionView reloadItemsAtIndexPaths:self.collectionView.indexPathsForVisibleItems];
        }
        
        
    });
    
}

#pragma mark - Helpers
-(STPost *) getCurrentPost{
    if (self.feedProcessor.numberOfPosts == 0) {
        return nil;
    }
    NSArray *visibleInxPath = self.collectionView.indexPathsForVisibleItems;
    STPost *post = [_feedProcessor postAtIndex:[[visibleInxPath objectAtIndex:0] row]];
    
    return post;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numRows = [_feedProcessor numberOfPosts];
    return numRows;
}

-(NSString *)identifierForPost:(STPost *)post{
    if ([post isLoadingPost] || !post.imageDownloaded)
        return loadingFeedCell;
    
    if (post.isNoPhotosToDisplayPost)
        return noPhotosToDisplayCell;
    
    if (post.isYouSawAllPost)
        return youSawAllCell;
    
    if (post.showFullCaption == YES) {
        return fullCaptionFeedCell;
    }
    
    return normalFeedCell;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    STPost *post = [_feedProcessor postAtIndex:indexPath.row];
    NSString *identifier = [self identifierForPost:post];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    if ([cell isKindOfClass:[FeedCell class]]) {
        [(FeedCell *)cell configureCellWithPost:post];
    }
    else if ([cell isKindOfClass:[FullCaptionFeedCell class]]){
        [(FullCaptionFeedCell *)cell configureCellWithPost:post];
    }
    else if ([cell isKindOfClass:[STNoPhotosCell class]]){
        [(STNoPhotosCell *)cell configureWitPost:post];
    }
    else if ([cell isKindOfClass:[FooterCell class]]){
        //TODO: dev_1_2
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

#pragma mark - IBACtions
- (IBAction)onLikePressed:(id)sender {
}
- (IBAction)onMessagePressed:(id)sender {
}
- (IBAction)onNamePressed:(id)sender {
}
- (IBAction)onSeeMorePressed:(id)sender {
    //TODO: dev_1_2 add animations
    STPost *post = [self getCurrentPost];
    [self.collectionView performBatchUpdates:^{
        post.showFullCaption = !post.showFullCaption;
        [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForVisibleItems]];
    } completion:nil];

}
- (IBAction)onLikesPressed:(id)sender {
}
- (IBAction)onMorePressed:(id)sender {
}
- (IBAction)onShadowPressed:(id)sender {
    //TODO: dev_1_2 add animations
    STPost *post = [self getCurrentPost];
    [self.collectionView performBatchUpdates:^{
        post.showFullCaption = !post.showFullCaption;
        [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForVisibleItems]];
    } completion:nil];
}


@end

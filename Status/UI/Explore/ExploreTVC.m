//
//  ExploreTVC.m
//  Status
//
//  Created by Andrus Cosmin on 28/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "ExploreTVC.h"
#import "STPostsPool.h"
#import "STPost.h"
#import "STImageCacheController.h"
#import "UIImage+ImageEffects.h"
#import "SmallFeedCVC.h"
#import "STFlowProcessor.h"
#import "STProcessorsService.h"
#import "FeedCVC.h"
#import "STNearbyController.h"

const CGFloat kHeaderHeight = 30.f;
const CGFloat kBottomHeight = 8.f;

@interface ExploreTVC ()
{
    STNearbyController *nearbyController;
}
@end

@implementation ExploreTVC

+ (ExploreTVC *)exploreController{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ExploreScene" bundle:nil];
    ExploreTVC *tvc = [storyboard instantiateViewControllerWithIdentifier:@"EXPLORE_TVC"];
    
    return tvc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    nearbyController = [STNearbyController new];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSmallFlowSelection:) name:kSmallFeedSelectionNotification object:nil];
    
}

- (void)setBackgroundImage:(UIImage *)bluredImg {
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.tableView.frame];
    backgroundView.backgroundColor = [UIColor clearColor];
    UIImage *bkImage = bluredImg;
    if (bkImage == nil) {
        bkImage = [STUIHelper splashImageWithLogo:NO];
    }
    UIImageView *bkImView = [[UIImageView alloc] initWithImage:bkImage];
    [backgroundView addSubview:bkImView];
    if (bluredImg!=nil) {
        UIView *darkView = [[UIView alloc] initWithFrame:self.tableView.frame];
        darkView.backgroundColor = [UIColor blackColor];
        darkView.alpha = 0.4;
        [backgroundView addSubview:darkView];
    }
    [self.tableView setBackgroundView:backgroundView];
}

-(void)viewWillAppear:(BOOL)animated{
    __weak typeof(self) weakSelf = self;
    [super viewWillAppear:animated];
    
    STPost * randomPost = [CoreManager postsPool].randomPost;
    
    if (randomPost != nil) {
        [[CoreManager imageCacheService] loadPostImageWithName:randomPost.mainImageUrl withPostCompletion:^(UIImage *origImg) {
            
        } andBlurCompletion:^(UIImage *bluredImg) {
            [weakSelf setBackgroundImage:bluredImg];
        }];
    }
    else
        [self setBackgroundImage:nil];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - SmallFlowNotification

-(void)onSmallFlowSelection:(NSNotification *)notif{
    STFlowType flowType = [notif.userInfo[kFlowTypeKey] integerValue];
    NSInteger offset = [notif.userInfo[kOffsetKey] integerValue];
    STFlowProcessor *feedProcessor = [[CoreManager processorService] getProcessorWithType:flowType];
    [feedProcessor setCurrentOffset:offset];
    if (flowType == STFlowTypeDiscoverNearby) {
        [nearbyController pushNearbyFlowFromController:self];
    }
    else
    {
        FeedCVC *feed = [FeedCVC feedControllerWithFlowProcessor:feedProcessor];
        [self.navigationController pushViewController:feed animated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 0.f;
    
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    
    height = (screenHeight - self.tableView.numberOfSections * kHeaderHeight - kBottomHeight- tabBarHeight)/3.f;
    
    return roundf(height);
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return kHeaderHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView
                       cellForRowAtIndexPath:indexPath];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView * headerview = (UITableViewHeaderFooterView *)view;
    headerview.backgroundView.backgroundColor = [UIColor clearColor];
    headerview.textLabel.textColor = [UIColor whiteColor];
    UIFont *font = [UIFont fontWithName:@"ProximaNova-Semibold" size:17.f];
    headerview.textLabel.font = font;

}

#pragma mark - UIStoryboardSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(nullable id)sender
{
    STFlowType flowType = STFlowTypeHome;
    NSString *identifier = segue.identifier;
    if ([identifier isEqualToString:@"POPULAR_FEED"]) {
        flowType = STFlowTypePopular;
    }
    else if ([identifier isEqualToString:@"NEARBY_FEED"]) {
        flowType = STFlowTypeDiscoverNearby;
    }
    else if ([identifier isEqualToString:@"RECENT_FEED"]) {
        flowType = STFlowTypeRecent;
    }
    else
    {
        NSLog(@"Never get it here. Debug if");
    }
    
    SmallFeedCVC *cvc = (SmallFeedCVC *)segue.destinationViewController;
    cvc.flowType = flowType;    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

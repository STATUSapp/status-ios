//
//  ContainerFeedVC.m
//  Status
//
//  Created by Cosmin Andrus on 30/11/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "ContainerFeedVC.h"
#import "STFacebookLoginController.h"
#import "STFlowProcessor.h"
#import "FeedCVC.h"

@interface ContainerFeedVC ()

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) STFlowProcessor *feedProcessor;
@property (nonatomic, assign) BOOL shouldAddBackButton;

@end

@implementation ContainerFeedVC

+ (ContainerFeedVC *)galleryFeedControllerForUserId:(NSString *)userId
                                        andUserName:(NSString *)userName{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FeedScene" bundle:nil];
    UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"CONTAINER_FEED_NAV"];
    ContainerFeedVC *feedCVC = [[navController viewControllers] firstObject];
    feedCVC.userName = userName;
    BOOL userIsMe = [[CoreManager loginService].currentUserUuid isEqualToString:userId];
    STFlowType flowType = userIsMe ? STFlowTypeMyGallery : STFlowTypeUserGallery;
    
    STFlowProcessor *feedProcessor = [[STFlowProcessor alloc] initWithFlowType:flowType userId:userId];
    feedCVC.feedProcessor = feedProcessor;
    feedCVC.shouldAddBackButton = YES;
    return feedCVC;
}

+ (ContainerFeedVC *)tabProfileController{
    ContainerFeedVC *feedVC = [ContainerFeedVC galleryFeedControllerForUserId:[[CoreManager loginService] currentUserUuid] andUserName:nil];
    feedVC.shouldAddBackButton = NO;
    return feedVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)extendedLayoutIncludesOpaqueBars{
    return YES;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Navigation
 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    FeedCVC *feedCVC = (FeedCVC *)segue.destinationViewController;
    [feedCVC setUserName:_userName];
    [feedCVC setFeedProcessor:_feedProcessor];
    if ([[_feedProcessor userId] isEqualToString:[CoreManager loginService].currentUserUuid]) {
        [feedCVC setIsMyProfile:YES];
    }
    feedCVC.shouldAddBackButton = _shouldAddBackButton;
}

@end

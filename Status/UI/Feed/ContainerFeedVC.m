//
//  ContainerFeedVC.m
//  Status
//
//  Created by Cosmin Andrus on 30/11/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "ContainerFeedVC.h"
#import "STLoginService.h"
#import "STFlowProcessor.h"
#import "FeedCVC.h"
#import "STDeepLinkService.h"
#import "STNavigationService.h"

@interface ContainerFeedVC ()<ContainerFeedCVCProtocol, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) STFlowProcessor *feedProcessor;
@property (nonatomic, assign) BOOL shouldAddBackButton;
@property (nonatomic, strong) FeedCVC *childFeedCVC;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *earningsBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *optionsBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsBarButton;
@property (strong, nonatomic) IBOutlet UIView *navBarLogoView;
@property (strong, nonatomic) IBOutlet UIImageView *navBarLogoImage;

@end

@implementation ContainerFeedVC

+ (ContainerFeedVC *)emptyContainer{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FeedScene" bundle:nil];
    UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"CONTAINER_FEED_NAV"];
    ContainerFeedVC *feedCVC = [[navController viewControllers] firstObject];
    return feedCVC;
}

+ (ContainerFeedVC *)galleryFeedControllerForUserId:(NSString *)userId
                                        andUserName:(NSString *)userName{
    ContainerFeedVC *feedCVC = [self emptyContainer];
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

+ (ContainerFeedVC *)homeFeedController{
    STFlowProcessor *feedProcessor = [[STFlowProcessor alloc] initWithFlowType:STFlowTypeHome];
    return [self feedControllerWithFlowProcessor:feedProcessor];
}

+ (ContainerFeedVC *)feedControllerWithFlowProcessor:(STFlowProcessor *)processor{
    ContainerFeedVC *feedCVC = [self emptyContainer];
    feedCVC.feedProcessor = processor;
    return feedCVC;
}

+ (ContainerFeedVC *)singleFeedControllerWithPostId:(NSString *)postId{
    STFlowProcessor *feedProcessor = [[STFlowProcessor alloc] initWithFlowType:STFlowTypeSinglePost postId:postId];
    return [self feedControllerWithFlowProcessor:feedProcessor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.feedProcessor.processorFlowType == STFlowTypeHome) {
        NSArray *redirectVC = [[CoreManager deepLinkService] redirectViewControllers];
        if (redirectVC && [redirectVC count]) {
            [[CoreManager navigationService] pushViewControllers:redirectVC
                                                 inTabbarAtIndex:STTabBarIndexHome];
        }
    }
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //deactivate this as it causes a leak on iOS 11
    self.navigationController.hidesBarsOnSwipe = NO;
    [self configureTheNavigationBar];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    NSLog(@"Dealloc called on ContainerFeedVC");
}

-(BOOL)extendedLayoutIncludesOpaqueBars{
    return YES;
}

-(BOOL)prefersStatusBarHidden{
    return NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

#pragma mark ContainerFeedCVCProtocol

-(void)configureNavigationBar{
    [self configureTheNavigationBar];
}
-(void)pushViewController:(UIViewController *)vc
                 animated:(BOOL)animated{
    [self.navigationController pushViewController:vc animated:animated];
}
-(void)presentViewController:(UIViewController *)viewController
                    animated:(BOOL)animated{
    [self.navigationController presentViewController:viewController animated:animated completion:nil];
}


#pragma mark - Helpers
- (NSString *)getFullName {
    NSString *fullName = [_feedProcessor.userProfile fullName];
    if (!fullName) {
        fullName = self.userName;
    }
    return fullName;
}

- (void)configureTheNavigationBar{
    UIViewController *currentViewController = [self.navigationController.viewControllers lastObject];
    if (self != currentViewController) {
        return;
    }
    if (self == currentViewController) {
        if (_feedProcessor.processorFlowType == STFlowTypeHome){
            self.navigationItem.titleView = _navBarLogoView;
        }
        else if (_feedProcessor.processorFlowType == STFlowTypeMyGallery) {
            NSString * fullName = [self getFullName];
            self.navigationItem.title = fullName;
            if (_feedProcessor.userProfile.isInfluencer) {
                self.navigationItem.leftBarButtonItems = @[_earningsBarButton];
            }else{
                self.navigationItem.leftBarButtonItems = nil;
            }
            self.navigationItem.rightBarButtonItems = @[_settingsBarButton];
        }
        else if (_feedProcessor.processorFlowType == STFlowTypeSinglePost)
        {
            self.navigationItem.title = NSLocalizedString(@"Photo", nil);
        }else if (_feedProcessor.processorFlowType == STFlowTypeHasttag){
            self.navigationItem.title = _feedProcessor.hashtag;
        }else if (_feedProcessor.processorFlowType == STFlowTypeUserGallery){
            NSString * fullName = [self getFullName];
            self.navigationItem.title = fullName;
            self.navigationItem.rightBarButtonItems = @[_optionsBarButton];
        }else if (_feedProcessor.processorFlowType ==  STFlowTypeTop){
            self.navigationItem.title = NSLocalizedString(@"Top Best Dressed People", nil);
        }
    }

    [self setNeedsStatusBarAppearanceUpdate];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


#pragma mark - Navigation
 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EMBEDED_FEED"]) {
        _childFeedCVC = (FeedCVC *)segue.destinationViewController;
        [_childFeedCVC setUserName:self.userName];
        [_childFeedCVC setFeedProcessor:self.feedProcessor];
        [_childFeedCVC setDelegate:self];
    }
}

#pragma mark - IBAction

- (IBAction)onOptionButtonPressed:(id)sender {
    [_childFeedCVC onProfileOptionsPressed:sender];
}
@end

@implementation UINavigationController (MultipleDrag)

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

@end

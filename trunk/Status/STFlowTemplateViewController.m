//
//  ViewController.m
//  Status
//
//  Created by Andrus Cosmin on 16/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STFlowTemplateViewController.h"
#import "STCustomCollectionViewCell.h"
#import "STWebServiceController.h"
#import <QuartzCore/QuartzCore.h>
#import "STSharePhotoViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "STImageCacheController.h"
#import "STFacebookController.h"
#import "STConstants.h"
#import "STCustomShareView.h"
#import "STLikesViewController.h"
#import "STLoginViewController.h"
#import "AppDelegate.h"
#import "STNotificationsViewController.h"
#import "STZoomablePostViewController.h"
#import "STFooterView.h"
#import "UIImage+ImageEffects.h"
#import "STTutorialViewController.h"
#import "STLocationManager.h"
#import "STChatRoomViewController.h"
#import "STConversationsListViewController.h"

#import "GADInterstitial.h"
#import "STRemoveAdsViewController.h"
#import "STInviteFriendsViewController.h"
#import "STInviteController.h"
#import "STMoveScaleViewController.h"

#import "STIAPHelper.h"
#import "STChatController.h"
#import "STFacebookAlbumsLoader.h"

#import "STSettingsViewController.h"

int const kDeletePostTag = 11;
int const kNoPostsAlertTag = 13;
int const kInviteUserToUpload = 14;
static NSString * const kSTTutorialIsSeen = @"Tutorial is already seen";

@interface STFlowTemplateViewController ()<UICollectionViewDataSource, UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout, UIActionSheetDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UIAlertViewDelegate, FacebookControllerDelegate, UIGestureRecognizerDelegate,
GADInterstitialDelegate, STTutorialDelegate, STSharePostDelegate>
{
    GADInterstitial * _interstitial;
    
    STCustomShareView *_shareOptionsView;
    NSLayoutConstraint *_shareOptionsViewContraint;
    NSDictionary *_lastNotif;
    UIButton *_refreshBt;
    BOOL _isPlaceholderSinglePost; // there is no dataSource and will be displayed a placeholder Post
    BOOL _isDataSourceLoaded;
    BOOL _isInterstitialLoaded;
    NSInteger _numberOfSeenPosts;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *notifBtn;
@property (weak, nonatomic) IBOutlet UILabel *notifNumberLabel;
@property (strong, nonatomic) UIButton * refreshBt;
@property (weak, nonatomic) IBOutlet UILabel *unreadMessagesLbl;

@property (strong, nonatomic) NSMutableArray *postsDataSource;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *leftSwipe;
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UIImageView *menuImageView;

@end

@implementation STFlowTemplateViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.postsDataSource = [NSMutableArray array];
    [[STFacebookController sharedInstance] setLogoutDelegate:self];
    
    if (self.flowType == STFlowTypeAllPosts)
        [[STFacebookController sharedInstance] setDelegate:self];
    
    NSString *email = [[STFacebookController sharedInstance] getUDValueForKey:LOGGED_EMAIL];
    
    if (self.flowType == STFlowTypeAllPosts)
    {
        if ([[[FBSession activeSession] accessTokenData] accessToken]==nil||email==nil) {
            [self presentLoginScene];
        }
    }
    else
    {
        [self getDataSourceWithOffset:0];
    }
    [self setupVisuals];
    [self initCustomShareView];
    [self updateNotificationsNumber];
    [self setUnreadMessagesNumber:[STChatController sharedInstance].unreadMessages];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateNotificationsNumber)
                                                 name:STNotificationBadgeValueDidChanged
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUnreadMessagesNumber)
                                                 name:STUnreadMessagesValueDidChanged
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(chatControllerAuthenticate)
                                                 name:STChatControllerAuthenticate
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(facebookPickerDidChooseImage:)
                                                 name:STFacebookPickerNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageWasSavedLocally:) name:STLoadImageNotification object:nil];
    
    
    
    // setup interstitial ad

    [self setupInterstitialAds];
    _numberOfSeenPosts = 0;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [self setNotificationsNumber:appDelegate.badgeNumber];
    [[STImageCacheController sharedInstance] changeFlowType:_flowType needsSort:YES];
}

- (void)presentTutorialAutomatically{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:kSTTutorialIsSeen] == nil) {
        [self onClickHowItWorks:nil];
        [[NSUserDefaults standardUserDefaults] setObject:kSTTutorialIsSeen forKey:kSTTutorialIsSeen];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _interstitial.delegate = nil;
}

-(void) presentLoginScene{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LoginScene" bundle:nil];
    STLoginViewController *viewController = (STLoginViewController *) [storyboard instantiateViewControllerWithIdentifier:@"loginScreen"];
    [self presentViewController:viewController animated:NO completion:nil];
}

-(void) initCustomShareView{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"STCustomShareView" owner:self options:nil];
    
    _shareOptionsView = (STCustomShareView*)[array objectAtIndex:0];
    _shareOptionsView.hidden = TRUE;
    _shareOptionsView.translatesAutoresizingMaskIntoConstraints = NO;
     [self.view addSubview:_shareOptionsView];

    _shareOptionsViewContraint = [NSLayoutConstraint constraintWithItem:_shareOptionsView
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.f
                                                               constant:0];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_shareOptionsView
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.f
                                                               constant:0];
    
    
    [self.view addConstraints:@[_shareOptionsViewContraint, bottomConstraint]];
    [_shareOptionsView setForDissmiss:YES];
    
}

#pragma mark - Setup Visuals for Flow Type

- (void)setupVisuals{
    self.notifNumberLabel.layer.cornerRadius = 7.f;
    self.unreadMessagesLbl.layer.cornerRadius = 7.f;
}

- (void)setNotificationsNumber: (NSInteger) notifNumber{
    if (notifNumber > 0) {
        self.notifNumberLabel.text = [NSString stringWithFormat:@" %zd ", notifNumber];
        self.notifNumberLabel.hidden = NO;
    }
    else{
        self.notifNumberLabel.hidden = YES;
    }
    
}

- (void)setUnreadMessagesNumber: (NSInteger) notifNumber{
    if (notifNumber > 0) {
        self.unreadMessagesLbl.text = [NSString stringWithFormat:@" %zd ", notifNumber];
        self.unreadMessagesLbl.hidden = NO;
    }
    else{
        self.unreadMessagesLbl.hidden = YES;
    }
    
}

- (void)updateNotificationsNumber{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [self setNotificationsNumber:app.badgeNumber];
}

-(void) updateUnreadMessagesNumber{
    [self setUnreadMessagesNumber:[STChatController sharedInstance].unreadMessages];
}

#pragma mark - AdMob delegate methods

- (void)setupInterstitialAds {
    _interstitial.delegate = nil;
    _interstitial = nil;
    
    _interstitial = [[GADInterstitial alloc] init];
    _interstitial.adUnitID = kSTAdUnitID;
    
//    request.testDevices = @[GAD_SIMULATOR_ID];
    
    [_interstitial loadRequest:[GADRequest request]];
    _interstitial.delegate = self;
    _isInterstitialLoaded = NO;
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    _isInterstitialLoaded = NO;
    NSLog(@"error %@", error.localizedDescription);
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    _isInterstitialLoaded = YES;
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    [self setupInterstitialAds];
}

#pragma mark - Interstitial Controllers method

- (void)presentInterstitialControllerForIndex:(NSInteger)index {
    
    if (index == 0 || index %15 != 0) {
        return;
    }
    BOOL shouldPresentAds = ![[STIAPHelper sharedInstance] productPurchased:kRemoveAdsInAppPurchaseProductID];
    
    if (shouldPresentAds) {
        [self presentInterstitialControllerWithType:STInterstitialTypeAds];
    }
    
}

- (void) presentInterstitialControllerWithType:(STInterstitialType)interstitialType {
    
    switch (interstitialType) {
        case STInterstitialTypeAds: {
            [_interstitial presentFromRootViewController:self];
            break;
        }
        case STInterstitialTypeRemoveAds: {
            STRemoveAdsViewController * removeAdsVC = [STRemoveAdsViewController newInstance];
            removeAdsVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:removeAdsVC animated:YES completion:nil];
            break;
        }
        case STInterstitialTypeInviter: {
            STInviteFriendsViewController * inviteFriendsVC = [STInviteFriendsViewController newInstance];
            inviteFriendsVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:inviteFriendsVC animated:YES completion:nil];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - STTutorialDelegate

-(void)tutorialDidDissmiss{
    if ([[STInviteController sharedInstance] shouldInviteBeAvailable]) {
        [self presentInterstitialControllerWithType:STInterstitialTypeInviter];
    }
}

#pragma mark - FacebookController Delegate

-(void)facebookControllerDidLoggedIn{
    __weak STFlowTemplateViewController * weakSelf = self;
    [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
        [weakSelf presentTutorialAutomatically];
    }];
    [self getDataSourceWithOffset:0];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate checkForNotificationNumber];
    [self handleNotification:_lastNotif];
}

-(void)facebookControllerDidLoggedOut{
    self.postsDataSource = [NSMutableArray array];
    UIViewController *presentedVC = self.presentedViewController;
    if (![presentedVC isKindOfClass:[STLoginViewController class]]) {
        [self dismissViewControllerAnimated:NO completion:^{
            [[STFacebookController sharedInstance] UDSetValue:nil forKey:PHOTO_LINK];
            [[STFacebookController sharedInstance] UDSetValue:nil forKey:USER_NAME];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[FBSession activeSession] closeAndClearTokenInformation];
            [[FBSession activeSession] close];
            [FBSession setActiveSession:nil];
            [[FBSessionTokenCachingStrategy defaultInstance] clearToken];
            [self.navigationController popToRootViewControllerAnimated:NO];
            [self presentLoginScene];
            [[STWebServiceController sharedInstance] setAPNToken:@"" withCompletion:^(NSDictionary *response) {
                if ([response[@"status_code"] integerValue]==200){
                    NSLog(@"APN Token deleted.");
                    [[STFacebookController sharedInstance] deleteAccessToken];
                }
                else  NSLog(@"APN token NOT deleted.");
            } orError:nil];
            
            [[STChatController sharedInstance] close];
        }];
    }
    
}

-(void)chatControllerAuthenticate{
    [self handleNotification:_lastNotif];
}

#pragma mark - STShareImageDelegate

-(void)imageWasPosted{
    STFlowTemplateViewController *flowCtrl = [self.storyboard instantiateViewControllerWithIdentifier: @"flowTemplate"];
    flowCtrl.flowType = STFlowTypeMyProfile;
    flowCtrl.userID = [STFacebookController sharedInstance].currentUserId;
    flowCtrl.userName = [[STFacebookController sharedInstance] getUDValueForKey:USER_NAME];
    AppDelegate *appDel=(AppDelegate *)[UIApplication sharedApplication].delegate;
    UINavigationController *navCtrl = (UINavigationController *)[appDel.window rootViewController];
    NSMutableArray *viewCtrl = [NSMutableArray arrayWithArray:navCtrl.viewControllers];
    //replace all the stack with the main flow and the user profile flow
    if ([[viewCtrl lastObject] isKindOfClass:[STSharePhotoViewController class]]) {
        NSArray *newFlow = @[[viewCtrl firstObject], flowCtrl];
        [navCtrl setViewControllers:newFlow animated:YES];
    }
}

-(void)imageWasEdited:(NSDictionary *)result{
    AppDelegate *appDel=(AppDelegate *)[UIApplication sharedApplication].delegate;
    UINavigationController *navCtrl = (UINavigationController *)[appDel.window rootViewController];
    NSMutableArray *viewCtrl = [NSMutableArray arrayWithArray:navCtrl.viewControllers];
    [viewCtrl removeLastObject];
    [viewCtrl removeLastObject];
    [navCtrl setViewControllers:viewCtrl animated:YES];
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:[self getCurrentDictionary]];
    NSInteger index = [_postsDataSource indexOfObject:dict];
    if ([dict[@"post_id"] isEqualToString:result[@"image_id"]]) {
        dict[@"full_photo_link"] = result[@"image_link"];
        [_postsDataSource replaceObjectAtIndex:index withObject:dict];
        [self.collectionView reloadData];
    }
}

#pragma mark - Get Data Source for Flow Type

-(NSMutableArray *)removeDuplicatesFromArray:(NSArray *)array{
    
    NSMutableArray *sheetArray = [NSMutableArray arrayWithArray:array];
    NSArray *idsArray = [_postsDataSource valueForKey:@"full_photo_link"];
    
    for (NSDictionary *dict in array) {
        if ([idsArray containsObject:dict[@"full_photo_link"]]) {
            NSLog(@"Duplicate found");
            [sheetArray removeObject:dict];
        }
    }
    return sheetArray;
}
-(void)imageWasSavedLocally:(NSNotification *)notif{
//    NSLog(@"Notif: %@", notif);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *currentDict = [self getCurrentDictionary];
        if ([[currentDict valueForKey:@"full_photo_link"] isEqualToString:notif.object]) {
            [self.collectionView reloadItemsAtIndexPaths:self.collectionView.indexPathsForVisibleItems];
        }
        
        
    });
    
}

- (void)getDataSourceWithOffset:(long) offset{
    NSLog(@"Offset: %ld", offset);
    __weak STFlowTemplateViewController *weakSelf = self;
    switch (self.flowType) {
        case STFlowTypeAllPosts:{
            [[STWebServiceController sharedInstance] getPostsWithOffset:offset withCompletion:^(NSDictionary *response) {
                
                if ([response[@"status_code"] integerValue] == STWebservicesSuccesCod) {
#if PAGGING_ENABLED
                    NSArray *newPosts = [self removeDuplicatesFromArray:response[@"data"]];
                    [weakSelf.postsDataSource addObjectsFromArray:newPosts];
#else
                    weakSelf.postsDataSource = [NSMutableArray arrayWithArray:response[@"data"]];
#endif
                    _isDataSourceLoaded = YES;
                    [weakSelf loadImages:newPosts];
                    [weakSelf.collectionView reloadData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.refreshBt setEnabled:YES];
                        [weakSelf.refreshBt setTitle:@"Refresh" forState:UIControlStateNormal];
                    });
                }
            } andErrorCompletion:^(NSError *error) {
                NSLog(@"error with %@", error.description);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.refreshBt setEnabled:YES];
                    [weakSelf.refreshBt setTitle:@"Refresh" forState:UIControlStateNormal];
                });
            }];
            break;
        }
        case STFlowTypeDiscoverNearby: {
            [[STWebServiceController sharedInstance] getNearbyPostsWithOffset:offset completion:^(NSDictionary *response) {
                
                if ([response[@"status_code"] integerValue] == 404) {
                    //user has no location force an update
                    
                    [[STLocationManager sharedInstance] startLocationUpdatesWithCompletion:^{
                        [weakSelf getDataSourceWithOffset:offset];
                    }];
                }
                else
                {
#if PAGGING_ENABLED
                    NSArray *newPosts = [self removeDuplicatesFromArray:response[@"data"]];
                    [weakSelf.postsDataSource addObjectsFromArray:newPosts];
#else
                    weakSelf.postsDataSource = [NSMutableArray arrayWithArray:response[@"data"]];
#endif
                    [weakSelf loadImages:newPosts];
                    _isDataSourceLoaded = YES;
                    [weakSelf.collectionView reloadData];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.refreshBt setEnabled:YES];
                    [weakSelf.refreshBt setTitle:@"Refresh" forState:UIControlStateNormal];
                });
                
            } andErrorCompletion:^(NSError *error) {
                NSLog(@"error with %@", error.description);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.refreshBt setEnabled:YES];
                    [weakSelf.refreshBt setTitle:@"Refresh" forState:UIControlStateNormal];
                });
            }];
            break;
        }
        case STFlowTypeMyProfile:
        case STFlowTypeUserProfile:{
            [[STWebServiceController sharedInstance] getUserPosts:self.userID withOffset:offset completion:^(NSDictionary *response) {
#if PAGGING_ENABLED
                NSArray *newPosts = [self removeDuplicatesFromArray:response[@"data"]];
                [weakSelf.postsDataSource addObjectsFromArray:newPosts];
#else
                weakSelf.postsDataSource = [NSMutableArray arrayWithArray:response[@"data"]];
#endif
                [weakSelf loadImages:newPosts];
                _isDataSourceLoaded = YES;
                [weakSelf.collectionView reloadData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.refreshBt setEnabled:YES];
                    [weakSelf.refreshBt setTitle:@"Refresh" forState:UIControlStateNormal];
                });
                
                
            } andErrorCompletion:^(NSError *error) {
                NSLog(@"error with %@", error.description);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.refreshBt setEnabled:YES];
                    [weakSelf.refreshBt setTitle:@"Refresh" forState:UIControlStateNormal];
                });
            }];
            break;
        }
        case STFlowTypeSinglePost:{
            [[STWebServiceController sharedInstance] getPostDetails:self.postID withCompletion:^(NSDictionary *response) {
                weakSelf.postsDataSource = [NSMutableArray arrayWithObject:response[@"data"]];
                [weakSelf loadImages:@[response[@"data"]]];
                _isDataSourceLoaded = YES;
                [weakSelf.collectionView reloadData];
            } andErrorCompletion:^(NSError *error) {
                
            }];
            break;
        }
        default:
            break;
    }
}
- (IBAction)onChatWithUser:(id)sender {
    NSDictionary *userInfo = [self getCurrentDictionary];
    if ([userInfo[@"user_id"] isEqualToString:[STFacebookController sharedInstance].currentUserId]) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"You cannot chat with yourself." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    if (![[STChatController sharedInstance] canChat]) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Chat connection appears to be offline right now. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
//#ifndef DEBUG
        return;
//#endif
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatScene" bundle:nil];
    STChatRoomViewController *viewController = (STChatRoomViewController *)[storyboard instantiateViewControllerWithIdentifier:@"chat_room"];
    viewController.userInfo = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)onChat:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatScene" bundle:nil];
    STConversationsListViewController *viewController = (STConversationsListViewController *)[storyboard instantiateViewControllerWithIdentifier:@"STConversationsListViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
    
}
#pragma mark - Actions
- (IBAction)onTapRefreshFromFooter:(id)sender {
    self.refreshBt = (UIButton *) sender;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshBt setEnabled:NO];
        [self.refreshBt setTitle:@"Refreshing..." forState:UIControlStateNormal];
        [self.refreshBt setTitle:@"Refreshing..." forState:UIControlStateHighlighted];
    });
    if(_flowType == STFlowTypeAllPosts)
        [self getDataSourceWithOffset:0];
    else
        [self getDataSourceWithOffset:_postsDataSource.count];
    
}

- (IBAction)onPinchCurrentPost:(id)sender {
    
    //avoid apple bug on receiving this event twice
    if (self.navigationController.presentedViewController==nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        STZoomablePostViewController *viewController = (STZoomablePostViewController *) [storyboard instantiateViewControllerWithIdentifier:@"zoomableView"];
        NSDictionary *dict = [self getCurrentDictionary];
        viewController.postPhotoLink = dict[@"full_photo_link"];
        [self presentViewController:viewController animated:NO completion:nil];
    }
}
- (IBAction)onDoubleTap:(id)sender {
    
    if (self.postsDataSource.count>0) {
        [self onTapLike:nil];
    }
}

- (void)pushFlowControllerWithType: (STFlowType)flowType{
    STFlowTemplateViewController *flowCtrl = [self.storyboard instantiateViewControllerWithIdentifier: @"flowTemplate"];
    flowCtrl.flowType = flowType;
    if (flowType==STFlowTypeUserProfile) {
        NSDictionary *dict = [self getCurrentDictionary];
        flowCtrl.userID = dict[@"user_id"];
        flowCtrl.userName = dict[@"user_name"];
    }
    
    [self.navigationController pushViewController:flowCtrl animated:YES];
}

- (IBAction)onTapProfileName:(id)sender {
    if (self.flowType == STFlowTypeUserProfile || self.flowType == STFlowTypeMyProfile) {
        //is already in user profile
        return;
    }
    [self pushFlowControllerWithType:STFlowTypeUserProfile];
}

-(IBAction)onTapMyProfile:(id)sender{
    [self onCloseMenu:nil];
    if (_flowType == STFlowTypeMyProfile) {
        return;
    }
    if ([STFacebookController sharedInstance].currentUserId == nil) {
        return;
    }
    STFlowTemplateViewController *flowCtrl = [self.storyboard instantiateViewControllerWithIdentifier: @"flowTemplate"];
    flowCtrl.flowType = STFlowTypeMyProfile;
    flowCtrl.userID = [STFacebookController sharedInstance].currentUserId;
    flowCtrl.userName = [[STFacebookController sharedInstance] getUDValueForKey:USER_NAME];
    [self.navigationController pushViewController:flowCtrl animated:YES];
}

- (IBAction)onTapShare:(id)sender {
    NSDictionary *dict = [self getCurrentDictionary];
    BOOL isOwner = [dict[@"is_owner"] boolValue];
    _shareOptionsView.shadowView.alpha = 0.0;
    [UIView animateWithDuration:0.33f animations:^{
        [_shareOptionsView setUpForThreeButtons:isOwner?NO:YES];
        _shareOptionsView.hidden=FALSE;
        _shareOptionsView.shadowView.alpha = 0.5;
        [_shareOptionsView setForDissmiss:NO];
        [self.view layoutIfNeeded];
        
    }];
    
}

- (IBAction)onSwipeLeftOnEdge:(id)sender {
    if (self.flowType == STFlowTypeAllPosts) {
        NSArray *indxPath = [self.collectionView indexPathsForVisibleItems];
        if (indxPath.count == 0) {
            return;
        }
        NSInteger currentRow = [[indxPath objectAtIndex:0] row];
        if (currentRow>0) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:currentRow-1 inSection:0]
                                        atScrollPosition:UICollectionViewScrollPositionNone
                                                animated:YES];
        }
        
    }
    else
    {
        NSArray *viewCtrl = self.navigationController.viewControllers;
        if (viewCtrl.count>=2) {
            UIViewController *preLastCtrl = [viewCtrl objectAtIndex:viewCtrl.count-2];
            if ([preLastCtrl isKindOfClass:[STLikesViewController class]]||
                [preLastCtrl isKindOfClass:[STNotificationsViewController class]]) {
                [self.navigationController popToViewController:[viewCtrl objectAtIndex:viewCtrl.count-3] animated:YES];
            }
            else
                [self.navigationController popViewControllerAnimated:YES];
        }
       
    }
}
- (IBAction)onCloseMenu:(id)sender {
    __weak STFlowTemplateViewController *weakSelf =self;
    [UIView animateWithDuration:0.33 animations:^{
        _menuView.alpha = 0.f;
    } completion:^(BOOL finished) {
        weakSelf.menuImageView.image = nil;
        [weakSelf.menuView removeFromSuperview];
    }];
    
}
- (IBAction)onClickHome:(id)sender {
    [self onCloseMenu:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self onClickSettings:sender];
}

- (IBAction)onClickSettings:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    STSettingsViewController * settingsCtrl = [storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([STSettingsViewController class])];
    UINavigationController   * setttingsNav = [[UINavigationController alloc] initWithRootViewController:settingsCtrl];
    [self presentViewController: setttingsNav animated:YES completion:nil];
}

- (IBAction)onClickHowItWorks:(id)sender {
    [self onCloseMenu:nil];
    STTutorialViewController * tutorialVC = [STTutorialViewController newInstance];
    tutorialVC.delegate = self;
    tutorialVC.backgroundImageForLastElement = [self snapshotOfCurrentScreen];
    tutorialVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:tutorialVC animated:YES completion:nil];
}
- (IBAction)onClickNearby:(id)sender {
    if (_flowType != STFlowTypeDiscoverNearby) {
        if (![STLocationManager locationUpdateEnabled]) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"You need to allow STATUS to access your location in order to see nearby friends." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
        else
        {
            [self onCloseMenu:nil];
            [self pushFlowControllerWithType:STFlowTypeDiscoverNearby];
        }
    }
    else
    {
        [self onCloseMenu:nil];
    }
}
- (IBAction)onClickNearbyFromYouSawAllThePhotos:(id)sender {
    [self onClickNearby:sender];
}
- (IBAction)onCLickInviteFriendsFromYouSawAllThePhotos:(id)sender {
    [self presentInterstitialControllerWithType:STInterstitialTypeInviter];
}

- (IBAction)onClickChatFromYouSawAllThePhotos:(id)sender {
    [self onChat:sender];
}

- (IBAction)onTapMenu:(id)sender {

    _menuView.alpha = 0.f;
    _menuImageView.image = [self blurCurrentScreen];
    
    [self.view addSubview:_menuView];

    [self addContraintForMenu];
    
    [UIView animateWithDuration:0.33 animations:^{
        _menuView.alpha = 1.f;
    }];
}

-(void)addContraintForMenu{
    [self.view addConstraint:[NSLayoutConstraint
                           constraintWithItem:_menuView
                           attribute:NSLayoutAttributeTop
                           relatedBy:NSLayoutRelationEqual
                           toItem:self.topLayoutGuide
                           attribute:NSLayoutAttributeTop
                           multiplier:1.f
                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:_menuView
                              attribute:NSLayoutAttributeBottom
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.bottomLayoutGuide
                              attribute:NSLayoutAttributeBottom
                              multiplier:1.f
                              constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:_menuView
                              attribute:NSLayoutAttributeTrailing
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeTrailing
                              multiplier:1.f
                              constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:_menuView
                              attribute:NSLayoutAttributeLeading
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeLeading
                              multiplier:1.f
                              constant:0]];
}

- (IBAction)onTapCameraUpload:(id)sender {
    
    UIActionSheet *actionChoose = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Take a Photo",@"Open Camera Roll",@"Upload from Facebook", nil];
    [actionChoose showFromRect: ((UIButton *)sender).frame inView:self.view animated:YES];
}

- (IBAction)onTapLike:(id)sender {
    [(UIButton *)sender setUserInteractionEnabled:NO];
    NSArray *indxPats = [self.collectionView indexPathsForVisibleItems];
    if (indxPats.count ==0) {
        return;
    }
    __block NSInteger currentRow = [[indxPats objectAtIndex:0] row];
    __block NSMutableDictionary *cellDict = [NSMutableDictionary dictionaryWithDictionary:self.postsDataSource[currentRow]];

    __weak STFlowTemplateViewController *weakSelf = self;
    [[STWebServiceController sharedInstance] setPostLiked:cellDict[@"post_id"] withCompletion:^(NSDictionary *response) {
        [(UIButton *)sender setUserInteractionEnabled:YES];
        if ([response[@"status_code"] integerValue]==STWebservicesSuccesCod) {

            [[STWebServiceController sharedInstance] getPostDetails:cellDict[@"post_id"] withCompletion:^(NSDictionary *response) {
                if ([response[@"status_code"] integerValue] == STWebservicesSuccesCod) {
                    
                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:response[@"data"]];
                    if (cellDict[@"post_seen"]!=nil) {
                        dict[@"post_seen"] = cellDict[@"post_seen"];
                    }
                    [weakSelf.postsDataSource replaceObjectAtIndex:currentRow
                                                    withObject:[NSDictionary dictionaryWithDictionary:dict]];
                    [weakSelf.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:currentRow inSection:0]]];
                    
                    BOOL isLiked = [cellDict[@"post_liked_by_current_user"] boolValue];
                    if (!isLiked && weakSelf.postsDataSource.count>currentRow+1) {
                        
                        [weakSelf performSelector:@selector(goToNextPostWithRow:)
                                       withObject:@(currentRow+1)
                                       afterDelay:0.33f];
                        
                    }

                }
            } andErrorCompletion:^(NSError *error) {
                
            }];
        }
        
    } orError:^(NSError *error) {
        [(UIButton *)sender setUserInteractionEnabled:YES];
    }];
}
- (IBAction)onTapBigCameraProfile:(id)sender {
    switch (self.flowType) {
        case STFlowTypeMyProfile:{
            [self onTapCameraUpload:sender];
            break;
        }
        case STFlowTypeUserProfile:{
            [self inviteUserToUpload];
            break;
        }
            
        default:
            return;
            break;
    }
}

-(void) inviteUserToUpload{
    //TODO: remove all completion blocks empty and check if nil supported
    __weak STFlowTemplateViewController *weakSelf = self;
    [[STWebServiceController sharedInstance] inviteUserToUpload:_userID withCompletion:^(NSDictionary *response) {
        NSInteger statusCode = [response[@"status_code"] integerValue];
        if (statusCode == STWebservicesSuccesCod || statusCode == STWebservicesFounded) {
            NSString *message = [NSString stringWithFormat:@"Congrats, you%@ asked %@ to take a photo.We'll announce you when his new photo is on STATUS.",statusCode == STWebservicesSuccesCod?@"":@" already", weakSelf.userName];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:message delegate:self
                                                  cancelButtonTitle:@"OK" otherButtonTitles:@"Go Home", nil];
            alert.tag = kInviteUserToUpload;
            [alert show];
            
        }
        else
        {
            NSLog(@"Error");
        }
    } orError:^(NSError *error) {
        
    }];
}

- (IBAction)onDismissShareOptions:(id)sender {
    [UIView animateWithDuration:0.33f animations:^{
        [_shareOptionsView setForDissmiss:YES];
        _shareOptionsView.shadowView.alpha = 0.0;
        [self.view layoutIfNeeded];
    }  completion:^(BOOL finished) {
        _shareOptionsView.hidden = TRUE;
    }];
}
- (IBAction)onSharePostToFacebook:(id)sender {
    __weak STFlowTemplateViewController *weakSelf = self;
    [self getCurrentImageDataWithCompletion:^(UIImage *img) {
        NSData *imgData = UIImageJPEGRepresentation(img, 1.0);
        [STFacebookAlbumsLoader loadPermissionsWithBlock:^(NSArray *newObjects) {
            NSLog(@"Permissions: %@", newObjects);
            if (![newObjects containsObject:@"publish_actions"]) {
                [[FBSession activeSession] requestNewPublishPermissions:@[@"publish_actions"]
                                                        defaultAudience:FBSessionDefaultAudienceFriends
                                                      completionHandler:^(FBSession *session, NSError *error) {
                                                          [weakSelf sharePhotoOnFacebookWithImgData:imgData];
                                                      }];
                
            }
            else
                [self sharePhotoOnFacebookWithImgData:imgData];
        }];
    }];
}

- (void)sharePhotoOnFacebookWithImgData:(NSData *)imgData{
    [[STFacebookController sharedInstance] shareImageWithData:imgData andCompletion:^(id result, NSError *error) {
        if(error==nil)
            [[[UIAlertView alloc] initWithTitle:@"Success"
                                        message:@"Your photo was posted."
                                       delegate:nil cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil] show];
        else
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:@"Something went wrong. You can try again later."
                                       delegate:nil cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil] show];
    }];
}

- (IBAction)onSavePostLocally:(id)sender {
    __weak STFlowTemplateViewController *weakSelf = self;
    [self getCurrentImageDataWithCompletion:^(UIImage *img) {
        UIImageWriteToSavedPhotosAlbum(img, weakSelf, @selector(thisImage:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), NULL);
    }];
    
}

-(IBAction)onMoveAndScale:(id)sender{
    NSDictionary *dict = [self getCurrentDictionary];
    __weak STFlowTemplateViewController *weakSelf = self;
    [[STImageCacheController sharedInstance] loadPostImageWithName:dict[@"full_photo_link"] andCompletion:^(UIImage *img, UIImage *bluredImg) {
        if (img!=nil) {
            [weakSelf startMoveScaleShareControllerForImage:img shouldCompress:NO editedPostId:dict[@"post_id"]];
        }
    }];
}

-(IBAction)onDeletePost:(id)sender{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Post"
                                                        message:@"Are you sure you want to delete this post?"
                                                       delegate:self cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Delete", nil];
    [alertView setTag:kDeletePostTag];
    [alertView show];
    
}
- (IBAction)onReportPost:(id)sender {
    NSDictionary *dict = [self getCurrentDictionary];

    if ([dict[@"report_status"] integerValue]==1) {
        [[STWebServiceController sharedInstance] setReportStatus:dict[@"post_id"] withCompletion:^(NSDictionary *response) {
            if ([response[@"status_code"] integerValue]==STWebservicesSuccesCod) {
                [[[UIAlertView alloc] initWithTitle:@"Report Post" message:@"A message was sent to the admin." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Report Post" message:@"This post was already reported." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }
            
        } orError:^(NSError *error) {
            
        }];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Report Post" message:@"This post was already reported." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}
- (void)thisImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo {
    if (error)
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Something went wrong. You can try again later."
                                   delegate:nil cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
    else
        [[[UIAlertView alloc] initWithTitle:@"Success"
                                    message:@"Your photo was saved."
                                   delegate:nil cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
}

-(void) getCurrentImageDataWithCompletion:(loadImageCompletion) completion{
    NSDictionary *dict = [self getCurrentDictionary];
#if !USE_SD_WEB
    [[STImageCacheController sharedInstance] loadImageWithName:dict[@"full_photo_link"] andCompletion:^(UIImage *img) {
        completion(img);
    } isForFacebook:NO];
#else
    [[STImageCacheController sharedInstance] loadImageWithName:dict[@"full_photo_link"] andCompletion:^(UIImage *img) {
        completion(img);
    }];
#endif
}

-(NSDictionary *) getCurrentDictionary{
    if (self.postsDataSource==nil||self.postsDataSource.count==0) {
        return [NSDictionary dictionary];
    }
    NSArray *visibleInxPath = self.collectionView.indexPathsForVisibleItems;
    NSDictionary *dict = [_postsDataSource lastObject];
    if (visibleInxPath.count != 0) 
        dict = [self.postsDataSource objectAtIndex:[[visibleInxPath objectAtIndex:0] row]];
    
    return dict;
}

-(void) goToNextPostWithRow:(NSNumber *) currentRow{
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:currentRow.integerValue inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionNone
                                            animated:YES];
}

#pragma mark - Collection View Data Source & Delegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    STCustomCollectionViewCell *cell = (STCustomCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"FlowCollectionCellIdentifier" forIndexPath:indexPath];
   
    if (_isPlaceholderSinglePost && !_isDataSourceLoaded) {
        [cell setUpPlaceholderBeforeLoading];
    }
    NSDictionary *cellDict = (_isPlaceholderSinglePost ? @{@"type":@"placeholder", @"content_loaded":@(_isDataSourceLoaded)} : self.postsDataSource[indexPath.row]); // the cell will know to setup as placeholder if setupDict is nil
    cell.username = self.userName;
    [cell setUpWithDictionary:cellDict forFlowType:self.flowType];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    _isPlaceholderSinglePost = NO;
    NSInteger numberOfItems = [self.postsDataSource count];
    
    switch (self.flowType) {
        case STFlowTypeAllPosts:
        case STFlowTypeDiscoverNearby:
            return numberOfItems;
            break;
        case STFlowTypeUserProfile:{
            if (numberOfItems > 0) {
                return numberOfItems;
            } else {
                _isPlaceholderSinglePost = YES;
                return 1; // there will be a placeholder post
            }
            break;
        }
        case STFlowTypeMyProfile:{
            if (numberOfItems > 0) {
                return numberOfItems;
            } else {
                _isPlaceholderSinglePost = YES;
                return 1; // there will be a placeholder post
            }
            break;
        }
            
        default:
            return numberOfItems;
            break;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.view.frame.size;
}
-(void)loadImages:(NSArray *)array{
    [[STImageCacheController sharedInstance] startImageDownloadForNewFlowType:_flowType andDataSource:array];
}

- (void)processLastPost {
    NSIndexPath *usedIndx = [[_collectionView indexPathsForVisibleItems] firstObject];
    if (usedIndx == nil) {
        usedIndx = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    else if (usedIndx.row>0) {
        usedIndx = [NSIndexPath indexPathForRow:usedIndx.row-1 inSection:usedIndx.section];
    }
    
    if (self.flowType == STFlowTypeAllPosts) {
        NSDictionary *dict = [self.postsDataSource objectAtIndex:usedIndx.row];
        if ([dict[@"post_seen"] boolValue] == TRUE) {
            return;
        }
        __weak STFlowTemplateViewController *weakSelf = self;
        [[STWebServiceController sharedInstance] setPostSeen:dict[@"post_id"] withCompletion:^(NSDictionary *response) {
            if ([response[@"status_code"] integerValue]==STWebservicesSuccesCod) {
                [weakSelf markDataSourceSeenAtIndex:usedIndx.row];
//                int indexOffset = usedIndx.row%POSTS_PAGGING;
//                if (indexOffset == POSTS_PAGGING - START_LOAD_OFFSET) {
//                    [weakSelf getDataSourceWithOffset:POSTS_PAGGING-indexOffset-1];
//                }
                BOOL shouldGetNextBatch = weakSelf.postsDataSource.count - usedIndx.row == START_LOAD_OFFSET && usedIndx.row!=0;
                if (shouldGetNextBatch) {
                    [weakSelf getDataSourceWithOffset:weakSelf.postsDataSource.count - usedIndx.row - 1];
                }
            }
            
        } orError:^(NSError *error) {
            NSLog(@"Post NOT set seen with error.");
        }];
    }
    else if(self.flowType != STFlowTypeSinglePost)
    {
//        if (usedIndx.row%POSTS_PAGGING == POSTS_PAGGING-START_LOAD_OFFSET) {
//            [self getDataSourceWithOffset:self.postsDataSource.count];
//        }
        BOOL shouldGetNextBatch = _postsDataSource.count - usedIndx.row == START_LOAD_OFFSET && usedIndx.row!=0;
        if (shouldGetNextBatch) {
            [self getDataSourceWithOffset:_postsDataSource.count];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    _numberOfSeenPosts++;
    [self presentInterstitialControllerForIndex:_numberOfSeenPosts];
    //TODO: move this call elsewhere. 
    [self processLastPost];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
#if PAGGING_ENABLED
    
#endif    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionFooter) {
        STFooterView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footerView" forIndexPath:indexPath];
        reusableview = headerView;
    }
    
    return reusableview;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    if (_flowType != STFlowTypeSinglePost) {
        return self.view.bounds.size;
    }
    
    return CGSizeZero;
}

-(void) markDataSourceSeenAtIndex:(long) index{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self.postsDataSource objectAtIndex:index]];
    [dict setValue:@(1) forKey:@"post_seen"];
    [self.postsDataSource replaceObjectAtIndex:index withObject:dict];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if ([gestureRecognizer isEqual:_leftSwipe]) {
        NSIndexPath *currentIndex = [self.collectionView.indexPathsForVisibleItems firstObject];
        if (currentIndex.row == 0) {
            return YES;
        }
    }
    
    return NO;
   
}

#pragma mark - UIActionSheetDelegate

- (void)presentFacebookPickerScene {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FacebookPickerScene" bundle:nil];
    UINavigationController *noteNav = [storyboard instantiateViewControllerWithIdentifier:@"FacebookPicker"];
    
    [self presentViewController:noteNav animated:YES completion:^{
        NSLog(@"Facebook Picker presented");
    }];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex==3) return;
    if (buttonIndex<=1) {
        @try {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.sourceType = (buttonIndex==0)?UIImagePickerControllerSourceTypeCamera:UIImagePickerControllerSourceTypePhotoLibrary|UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            
            [self presentViewController:imagePicker animated:YES completion:^{
                
            }];
        }
        @catch (NSException *exception) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device has no camera." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else
    {
        __weak STFlowTemplateViewController *weakSelf = self;
        [STFacebookAlbumsLoader loadPermissionsWithBlock:^(NSArray *newObjects) {
            NSLog(@"Permissions: %@", newObjects);
            if (![newObjects containsObject:@"user_photos"]) {
                [[FBSession activeSession] requestNewPublishPermissions:@[@"user_photos"]
                                                        defaultAudience:FBSessionDefaultAudienceFriends
                                                      completionHandler:^(FBSession *session, NSError *error) {
                                                          if (!error) {
                                                              [weakSelf presentFacebookPickerScene];
                                                          }
                                                          else
                                                          {
                                                              [[[UIAlertView alloc] initWithTitle:@"Error" message:@"There was a problem with facebook at this time. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                                                          }
                                                      }];
            }
            else
                [weakSelf presentFacebookPickerScene];
        }];
        
    }
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kNoPostsAlertTag) {
        [self onTapMenu:nil];
    }
    else if (alertView.tag == kDeletePostTag)
    {
        if (buttonIndex==1) {
            NSDictionary *dict = [self getCurrentDictionary];
            __weak STFlowTemplateViewController *weakSelf = self;
            [[STWebServiceController sharedInstance] deletePost:dict[@"post_id"] withCompletion:^(NSDictionary *response) {
                
                if ([response[@"status_code"] integerValue] == STWebservicesSuccesCod) {
                    //animate cell out
                    [weakSelf.collectionView performBatchUpdates:^{
                        
                        NSArray *selectedItemsIndexPaths = [self.collectionView indexPathsForVisibleItems];
                        // Delete the items from the data source.
                        [weakSelf deleteItemsFromDataSourceAtIndexPaths:selectedItemsIndexPaths];
                        // Now delete the items from the collection view.
                        if ([weakSelf.postsDataSource count]) {
                            [weakSelf.collectionView deleteItemsAtIndexPaths:selectedItemsIndexPaths];
                        } else {
                            NSIndexPath *firstIndx = [NSIndexPath indexPathForRow:0 inSection:0];
                            [weakSelf.collectionView reloadItemsAtIndexPaths:@[firstIndx]];
                        }
                        
                        
                    } completion:nil];
                }
                
            } orError:^(NSError *error) {
                NSLog(@"POST NOT DELETED: %@", error);
            }];
            
        }
    }
    else if (alertView.tag == kInviteUserToUpload){
        if (buttonIndex ==1) {
            [self onTapMenu:nil];
        }
    }
    
}

// This method is for deleting the current dict from the data source array
-(void)deleteItemsFromDataSourceAtIndexPaths:(NSArray  *)itemPaths
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (NSIndexPath *itemPath  in itemPaths) {
        [indexSet addIndex:itemPath.row];
        
    }
    [self.postsDataSource removeObjectsAtIndexes:indexSet];
    
}

#pragma mark - UIImagePickerDelegate
-(void)facebookPickerDidChooseImage:(NSNotification *)notif{
    NSLog(@"self.navigationController.viewControllers =  %@", self.navigationController.presentedViewController);
    __weak STFlowTemplateViewController *weakSelf = self;
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [weakSelf startMoveScaleShareControllerForImage:(UIImage *)[notif object]
                                     shouldCompress:NO
                                       editedPostId:nil];
    }];

}

- (void)startMoveScaleShareControllerForImage:(UIImage *)img
                               shouldCompress:(BOOL)compressing
                                    editedPostId:(NSString *)postId{
    
    // here, no compressing should be done, because it might be a cropping after this
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    STMoveScaleViewController *viewController = (STMoveScaleViewController *)[storyboard instantiateViewControllerWithIdentifier:@"STMoveScaleViewController"];
    viewController.currentImg = img;
    viewController.delegate = self;
    viewController.editPostId = postId;
    [self.navigationController pushViewController:viewController animated:NO];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    __weak STFlowTemplateViewController *weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImage *fixedOrientationImage = [UIImage imageWithCGImage:img.CGImage
                                                             scale:img.scale
                                                       orientation:img.imageOrientation];

        [weakSelf startMoveScaleShareControllerForImage:fixedOrientationImage shouldCompress:YES editedPostId:nil];
    }];
    
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqualToString:@"likesSegue"]) {
        NSDictionary *dict = [self getCurrentDictionary];
        if ([dict[@"number_of_likes"] integerValue]==0) {
            return NO;
        }
    }
//    else if ([identifier isEqualToString:@"notifSegue"]){
//        if (self.flowType == STFlowTypeSinglePost) {
//            return NO;
//        }
//    }
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"likesSegue"]) {
        
        NSDictionary *dict = [self getCurrentDictionary];
        STLikesViewController *viewController = (STLikesViewController *)[segue destinationViewController];
        viewController.postId = dict[@"post_id"];
    }
    else if ([segue.identifier isEqualToString:@"inviteSegue"]){
        [self onCloseMenu:nil];
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

#pragma mark - Helper

-(void) handleNotification:(NSDictionary *) notif{
    if (notif == nil) {
        return;
    }
    UIViewController *lastVC = [self.navigationController.viewControllers lastObject];
    if ([lastVC isKindOfClass:[STFlowTemplateViewController class]]) {
        
        if ([notif[@"user_info"][@"notification_type"] integerValue] == 4) {
            if (![[STChatController sharedInstance] canChat]) {
                _lastNotif = notif;
                return;
            }
            _lastNotif = nil;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatScene" bundle:nil];
            STChatRoomViewController *viewController = (STChatRoomViewController *)[storyboard instantiateViewControllerWithIdentifier:@"chat_room"];
            viewController.userInfo = [NSMutableDictionary dictionaryWithDictionary:notif[@"user_info"]];
            [self.navigationController pushViewController:viewController animated:YES];
        }
        else
        {
            if ([STWebServiceController sharedInstance].accessToken == nil) {
                //wait for the login to be performed and after handle the notification
                _lastNotif = notif;
                return;
            }
            _lastNotif = nil;
            [self performSegueWithIdentifier:@"notifSegue" sender:nil];
        }
}
    else if ([lastVC isKindOfClass:[STNotificationsViewController class]]){
        [(STNotificationsViewController *)lastVC getNotificationsFromServer];
    }
}

-(UIImage *)blurCurrentScreen{
    UIImage * imageFromCurrentView = [self snapshotOfCurrentScreen];
    return [imageFromCurrentView applyDarkEffect];
}

- (UIImage *)snapshotOfCurrentScreen{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:context];
    UIImage *imageFromCurrentView = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageFromCurrentView;
}



@end

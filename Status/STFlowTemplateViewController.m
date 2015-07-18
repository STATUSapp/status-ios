//
//  ViewController.m
//  Status
//
//  Created by Andrus Cosmin on 16/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STFlowTemplateViewController.h"
#import "STCustomCollectionViewCell.h"
#import "STNetworkQueueManager.h"
#import <QuartzCore/QuartzCore.h>
#import "STSharePhotoViewController.h"
#import "STImageCacheController.h"
#import "STFacebookLoginController.h"
#import "STConstants.h"
#import "STCustomShareView.h"
#import "STUsersListController.h"
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
#import "STMenuView.h"
#import "UIImage+FixedOrientation.h"

#import "STRemoveAdsViewController.h"
#import "STInviteFriendsViewController.h"
#import "STInviteController.h"
#import "STMoveScaleViewController.h"

#import "STIAPHelper.h"
#import "STChatController.h"
#import "STFacebookHelper.h"

#import "STSettingsViewController.h"
#import <Crashlytics/Crashlytics.h>

#import "STGetPostsRequest.h"
#import "STSetPostLikeRequest.h"
#import "STRepostPostRequest.h"
#import "STGetUserPostsRequest.h"
#import "STGetNearbyProfilesRequest.h"
#import "STSetPostSeenRequest.h"
#import "STSetAPNTokenRequest.h"
#import "STGetPostDetailsRequest.h"
#import "STDeletePostRequest.h"
#import "STInviteUserToUploadRequest.h"
// temporary - needs refactoring for menu
#import "STUserProfileViewController.h"

#import "STNotificationsManager.h"
#import "STMenuController.h"
#import "STUpdateToNewerVersionController.h"
#import "STImagePickerController.h"
#import "STNoPhotosCell.h"

#import "STGetUserProfileRequest.h"
#import "STEditProfileViewController.h"
#import "STSuggestionsViewController.h"

#import <FBSDKCoreKit.h>

int const kDeletePostTag = 11;
int const kInviteUserToUpload = 14;
static NSString * const kSTTutorialIsSeen = @"Tutorial is already seen";

@interface STFlowTemplateViewController ()<UICollectionViewDataSource, UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout, UIActionSheetDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UIAlertViewDelegate, FacebookControllerDelegate, UIGestureRecognizerDelegate,STSharePostDelegate>
{    
    STCustomShareView *_shareOptionsView;
    NSLayoutConstraint *_shareOptionsViewContraint;
    UIButton *_refreshBt;
    BOOL _isPlaceholderSinglePost; // there is no dataSource and will be displayed a placeholder Post
    BOOL _isDataSourceLoaded;
//    NSInteger _numberOfSeenPosts;
    
    CGPoint _start;
    CGPoint _end;
    
    BOOL _shouldForceSetSeen;
    
    BOOL _pinching;
    
    NSInteger _numberOfDuplicates;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *notifNumberLabel;
@property (strong, nonatomic) UIButton * refreshBt;
@property (weak, nonatomic) IBOutlet UILabel *unreadMessagesLbl;

@property (strong, nonatomic) NSMutableArray *postsDataSource;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *leftSwipe;
@end

@implementation STFlowTemplateViewController

#pragma mark - Lifecycle

+(STFlowTemplateViewController *)getFlowControllerWithFlowType:(STFlowType)flowType{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *nvc = [storyboard instantiateInitialViewController];
    STFlowTemplateViewController *vc = (STFlowTemplateViewController *)[[nvc viewControllers] firstObject];
    vc.flowType = flowType;
    return vc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.postsDataSource = [NSMutableArray array];
    _numberOfDuplicates = 0;
    if (self.flowType == STFlowTypeHome)
        [[STFacebookLoginController sharedInstance] setDelegate:self];
    else
        [self getDataSourceWithOffset:0];
    
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
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(facebookPickerDidChooseImage:)
//                                                 name:STFacebookPickerNotification
//                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageWasSavedLocally:) name:STLoadImageNotification object:nil];
    
    
//deactivate ads as Denis requested
    // setup interstitial ad
//    _GADelegate = [STGADelegate new];
//    [_GADelegate setupInterstitialAds];
//    [self setupInterstitialAds];
//    _numberOfSeenPosts = 0;
  
    //fall back foe cases where this is not properly setted.
    if (_flowType == STFlowTypeUserGallery && [_userID isEqualToString:[STFacebookLoginController sharedInstance].currentUserId]) {
        _flowType = STFlowTypeMyGallery;
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([FBSDKAccessToken currentAccessToken]==nil||
        [STFacebookLoginController sharedInstance].currentUserId==nil) {
        [self presentLoginScene];
    }
    else
    {
        if (_shouldActionCameraBtn) {
            _shouldActionCameraBtn = NO;
            [self onTapCameraUpload:nil];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[STFacebookLoginController sharedInstance] setLogoutDelegate:self];
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [self setNotificationsNumber:appDelegate.badgeNumber];
    [[STImageCacheController sharedInstance] changeFlowType:_flowType needsSort:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    //remove the delegate will prevent scroll to call functions after the view did not exists
    [self.collectionView setDelegate:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) presentLoginScene{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LoginScene" bundle:nil];
    STLoginViewController *viewController = (STLoginViewController *) [storyboard instantiateViewControllerWithIdentifier:@"loginScreen"];

    AppDelegate *appDel=(AppDelegate *)[UIApplication sharedApplication].delegate;
    UINavigationController *navCtrl = (UINavigationController *)[appDel.window rootViewController];

    [navCtrl presentViewController:viewController animated:NO completion:^{
        [self.navigationController popToRootViewControllerAnimated:NO];
    }];
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
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:_shareOptionsView
                                                                        attribute:NSLayoutAttributeLeading
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeLeading
                                                                       multiplier:1.f
                                                                         constant:0];

    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:_shareOptionsView
                                                                        attribute:NSLayoutAttributeTrailing
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeTrailing
                                                                       multiplier:1.f
                                                                         constant:0];

    
    
    [self.view addConstraints:@[_shareOptionsViewContraint, bottomConstraint, leftConstraint, rightConstraint]];
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

#pragma mark - Interstitial Controllers method

- (void)presentInterstitialControllerForIndex:(NSInteger)index {
    
    if (index == 0 || index %15 != 0) {
        return;
    }
    //disable this as Denis requested
    BOOL shouldPresentAds = ![[STIAPHelper sharedInstance] productPurchased:kRemoveAdsInAppPurchaseProductID];
    
    if (shouldPresentAds) {
        [self presentInterstitialControllerWithType:STInterstitialTypeAds];
    }
    
}

- (void) presentInterstitialControllerWithType:(STInterstitialType)interstitialType {
    
    switch (interstitialType) {
        case STInterstitialTypeAds: {
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

#pragma mark - FacebookController Delegate
-(void)facebookControllerDidRegister{
    NSString *userId = [STFacebookLoginController sharedInstance].currentUserId;
    [STGetUserProfileRequest getProfileForUserID:userId withCompletion:^(id response, NSError *error) {
        NSLog(@"%@", response);
        STEditProfileViewController * editVC = [STEditProfileViewController newControllerWithUserId:userId];
        editVC.userProfile = [STUserProfile userProfileWithDict:response];
        [self.navigationController pushViewController:editVC animated:YES];
        
        
    } failure:^(NSError *error) {
        // empty all fields
        NSLog(@"%@", error.debugDescription);
    }];

}
-(void)facebookControllerDidLoggedIn{
    
    if (![self.presentedViewController isBeingDismissed])
    {
        if ([self.presentedViewController isKindOfClass:[STLoginViewController class]]) {
            [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
            //TODO: add this call only first time ?
            __block NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            BOOL suggestionsShown = [[ud valueForKey:@"SUGGESTIONS_SHOWED"] boolValue];
            if(suggestionsShown == NO)
            {
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"SuggestionsScene" bundle:nil];
                STSuggestionsViewController *vc = (STSuggestionsViewController *)[storyBoard instantiateInitialViewController];
                [self.navigationController presentViewController:vc animated:NO completion:^{
                    [ud setValue:@(YES) forKey:@"SUGGESTIONS_SHOWED"];
                    [ud synchronize];
                }];
            }
        }
    }
    
    [self getDataSourceWithOffset:0];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate checkForNotificationNumber];
    //deativate this feature until 
//    [[STUpdateToNewerVersionController sharedManager] checkForAppInfo];
    [[STNotificationsManager sharedManager] handleLastNotification];
}

-(void)facebookControllerDidLoggedOut{
    self.postsDataSource = [NSMutableArray array];
//    __weak STFlowTemplateViewController *weakSelf = self;
    UIViewController *presentedVC = self.presentedViewController;

    if (![presentedVC isKindOfClass:[STLoginViewController class]]) {
        [self dismissViewControllerAnimated:NO completion:^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
    }
    
}

-(void)facebookControllerSessionExpired{
    [self presentLoginScene];
}

-(void)chatControllerAuthenticate{
    [[STNotificationsManager sharedManager] handleLastNotification];
}

#pragma mark - STShareImageDelegate

-(void)imageWasPostedWithPostId:(NSString *)postId{
    
    AppDelegate *appDel=(AppDelegate *)[UIApplication sharedApplication].delegate;
    UINavigationController *navCtrl = (UINavigationController *)[appDel.window rootViewController];
    NSMutableArray *viewCtrl = [NSMutableArray arrayWithArray:navCtrl.viewControllers];
    //replace all the stack with the main flow and the user profile flow
    
    STFlowTemplateViewController *flowCtrl;
    
    if (postId) {
        flowCtrl = [self.storyboard instantiateViewControllerWithIdentifier: @"flowTemplate"];
        flowCtrl.flowType = STFlowTypeSinglePost;
        flowCtrl.userID = [STFacebookLoginController sharedInstance].currentUserId;
        flowCtrl.userName = [STFacebookLoginController sharedInstance].fetchedUserData[@"full_name"];
        flowCtrl.postID = postId;
    }
    
    if ([[viewCtrl lastObject] isKindOfClass:[STSharePhotoViewController class]]) {
        NSArray *newFlow = postId ? @[viewCtrl.firstObject, flowCtrl] : @[viewCtrl.firstObject];
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

#pragma mark - STEditCaptionDelegate
-(void)captionWasEditedForPost:(NSDictionary *)postDict withNewCaption:(NSString *)newCaption{
    NSInteger editedPostRow = [[_postsDataSource valueForKey:@"post_id"] indexOfObject:postDict[@"post_id"]];
    NSMutableDictionary *newPostDict = [NSMutableDictionary dictionaryWithDictionary:[_postsDataSource objectAtIndex:editedPostRow]];
    newPostDict[@"caption"] = newCaption;
    
    [_postsDataSource replaceObjectAtIndex:editedPostRow withObject:newPostDict];
    [_collectionView reloadData];
}

#pragma mark - Get Data Source for Flow Type

-(NSMutableArray *)removeDuplicatesFromArray:(NSArray *)array{
    
//#ifdef DEBUG
//    NSMutableArray *sheetArray = [NSMutableArray new];
//    for (NSDictionary *dict in array) {
//        NSMutableDictionary *dict1 = [NSMutableDictionary dictionaryWithDictionary:dict];
//        [sheetArray addObject:dict1];
//    }
//#else
    NSMutableArray *sheetArray = [NSMutableArray arrayWithArray:array];
//#endif
    NSArray *idsArray = [_postsDataSource valueForKey:@"full_photo_link"];
    
    for (NSDictionary *dict in array) {
        if ([idsArray containsObject:dict[@"full_photo_link"]]) {
            NSLog(@"Duplicate found");
            [sheetArray removeObject:dict];
            _numberOfDuplicates++;
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
        case STFlowTypePopular:
        case STFlowTypeHome:
        case STFlowTypeRecent:
        {
            
            STRequestCompletionBlock completion = ^(id response, NSError *error){
                if ([response[@"status_code"] integerValue] == STWebservicesSuccesCod) {
                    NSArray *newPosts = [self removeDuplicatesFromArray:response[@"data"]];
//#ifdef DEBUG
//                    [newPosts setValue:@"Tra la la la la la la ll llalalalal lal lalalal lalalal lalala" forKey:@"caption"];
//#endif
                    [weakSelf.postsDataSource addObjectsFromArray:newPosts];
                    _isDataSourceLoaded = YES;
                    [weakSelf loadImages:newPosts];
                    [weakSelf.collectionView reloadData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.refreshBt setEnabled:YES];
                        [weakSelf.refreshBt setTitle:@"Refresh" forState:UIControlStateNormal];
                    });
                }
            };
            STRequestFailureBlock failBlock = ^(NSError *error){
                NSLog(@"error with %@", error.description);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.refreshBt setEnabled:YES];
                    [weakSelf.refreshBt setTitle:@"Refresh" forState:UIControlStateNormal];
                });
            };
            [STGetPostsRequest getPostsWithOffset:offset flowType:_flowType
                                   withCompletion:completion failure:failBlock];
            break;
        }
        case STFlowTypeDiscoverNearby: {
            
            STRequestCompletionBlock completion = ^(id response, NSError *error){
                if ([response[@"status_code"] integerValue] == 404) {
                    //user has no location force an update
                    
                    [[STLocationManager sharedInstance] startLocationUpdatesWithCompletion:^{
                        [weakSelf getDataSourceWithOffset:offset];
                    }];
                }
                else
                {
                    NSArray *newPosts = [self removeDuplicatesFromArray:response[@"data"]];
                    [weakSelf.postsDataSource addObjectsFromArray:newPosts];
                    [weakSelf loadImages:newPosts];
                    _isDataSourceLoaded = YES;
                    [weakSelf.collectionView reloadData];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.refreshBt setEnabled:YES];
                    [weakSelf.refreshBt setTitle:@"Refresh" forState:UIControlStateNormal];
                });
            };
            
            STRequestFailureBlock failBlock = ^(NSError *error){
                NSLog(@"error with %@", error.description);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.refreshBt setEnabled:YES];
                    [weakSelf.refreshBt setTitle:@"Refresh" forState:UIControlStateNormal];
                });
            };
            
            [STGetNearbyProfilesRequest getNearbyProfilesWithOffset:offset
                                               withCompletion:completion
                                                      failure:failBlock];
            
            break;
        }
        case STFlowTypeMyGallery:
        case STFlowTypeUserGallery:{
            
            STRequestCompletionBlock completion = ^(id response, NSError *error){
                if ([response[@"status_code"] integerValue] == STWebservicesSuccesCod) {
                    NSArray *newPosts = [self removeDuplicatesFromArray:response[@"data"]];
                    [weakSelf.postsDataSource addObjectsFromArray:newPosts];
                    [weakSelf loadImages:newPosts];
                    _isDataSourceLoaded = YES;
                    [weakSelf.collectionView reloadData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.refreshBt setEnabled:YES];
                        [weakSelf.refreshBt setTitle:@"Refresh" forState:UIControlStateNormal];
                    });
                }
            };
            
            STRequestFailureBlock failBlock = ^(NSError *error){
                NSLog(@"error with %@", error.description);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.refreshBt setEnabled:YES];
                    [weakSelf.refreshBt setTitle:@"Refresh" forState:UIControlStateNormal];
                });
            };
            
            [STGetUserPostsRequest getPostsForUser:_userID withOffset:offset withCompletion:completion failure:failBlock];
            
            break;
        }
        case STFlowTypeSinglePost:{
            STRequestCompletionBlock completion = ^(id response, NSError *error){
                if ([response[@"status_code"] integerValue]==STWebservicesSuccesCod) {
                    weakSelf.postsDataSource = [NSMutableArray arrayWithObject:response[@"data"]];
                    [weakSelf loadImages:@[response[@"data"]]];
                    _isDataSourceLoaded = YES;
                    [weakSelf.collectionView reloadData];
                }
            };
            [STGetPostDetailsRequest getPostDetails:_postID withCompletion:completion failure:nil];
            break;
        }
        default:
            break;
    }
}
- (IBAction)onChatWithUser:(id)sender {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[self getCurrentDictionary]];
//    if (![[STChatController sharedInstance] canChat]) {
//        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Chat connection appears to be offline right now. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
////#ifndef DEBUG
//        return;
////#endif
//    }
    
    if (userInfo[@"user_id"]==nil && _userID!=nil) {
        userInfo[@"user_id"]=_userID;
    }
    if ([userInfo[@"user_id"] isEqualToString:[STFacebookLoginController sharedInstance].currentUserId]) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"You cannot chat with yourself." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
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

- (IBAction)onTapMenu:(id)sender {
    [[STMenuController sharedInstance] showMenuForController:self];
}
- (IBAction)onTapRefreshFromFooter:(id)sender {
    self.refreshBt = (UIButton *) sender;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshBt setEnabled:NO];
        [self.refreshBt setTitle:@"Refreshing..." forState:UIControlStateNormal];
        [self.refreshBt setTitle:@"Refreshing..." forState:UIControlStateHighlighted];
    });
    if(_flowType == STFlowTypePopular ||
       _flowType == STFlowTypeHome ||
       _flowType == STFlowTypeRecent)
        [self getDataSourceWithOffset:0];
    else
        [self getDataSourceWithOffset:_postsDataSource.count+_numberOfDuplicates];
    
}

- (IBAction)onPinchCurrentPost:(id)sender {
    //avoid apple bug on receiving this event twice
    if (_pinching == NO) {
        _pinching = YES;
        NSDictionary *dict = [self getCurrentDictionary];
        __block UIImage *fullImage = nil;
        __block UIImage *bluredImage = nil;
        __weak STFlowTemplateViewController *weakSelf = self;
        [[STImageCacheController sharedInstance] loadPostImageWithName:dict[@"full_photo_link"] withPostCompletion:^(UIImage *origImg) {
            fullImage = origImg;
            [weakSelf presentZoomablePostWithFullImage:fullImage andBluredImage:bluredImage];
            
        } andBlurCompletion:^(UIImage *bluredImg) {
            if (bluredImg!=nil) {
                bluredImage = bluredImg;
                [weakSelf presentZoomablePostWithFullImage:fullImage andBluredImage:bluredImage];
            }
        }];
    }
}

-(void)presentZoomablePostWithFullImage:(UIImage *)fullImage andBluredImage:(UIImage *)bluredImage{
    if (fullImage==nil || bluredImage == nil) {
        NSLog(@"Skip for now!");
        return;
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    STZoomablePostViewController *viewController = (STZoomablePostViewController *) [storyboard instantiateViewControllerWithIdentifier:@"zoomableView"];
    viewController.fullImage = fullImage;
    viewController.bluredImage = bluredImage;
    [self presentViewController:viewController animated:NO completion:^{
        _pinching = NO;
    }];
}
- (IBAction)onDoubleTap:(id)sender {
    
    if (self.postsDataSource.count>0) {
        [self onTapLike:nil];
    }
}

- (void)pushFlowControllerWithType: (STFlowType)flowType{
    STFlowTemplateViewController *flowCtrl = [self.storyboard instantiateViewControllerWithIdentifier: @"flowTemplate"];
    flowCtrl.flowType = flowType;
    
    [self.navigationController pushViewController:flowCtrl animated:YES];
}

- (IBAction)onTapProfileName:(id)sender {
    if (self.flowType == STFlowTypeUserGallery || self.flowType == STFlowTypeMyGallery) {
        //is already in user profile
        return;
    }
    
    NSDictionary *dict = [self getCurrentDictionary];
    STUserProfileViewController * userProfileVC = [STUserProfileViewController newControllerWithUserId:dict[@"user_id"]];
    [self.navigationController pushViewController:userProfileVC animated:YES];
}

-(IBAction)onTapMyProfile:(id)sender{
        
    STUserProfileViewController * userProfileVC = [STUserProfileViewController newControllerWithUserId:[STFacebookLoginController sharedInstance].currentUserId];
    [self.navigationController pushViewController:userProfileVC animated:YES];
}
- (IBAction)onTapUserProfilePicture:(id)sender {
    NSString *userId = [[self getCurrentDictionary] valueForKey:@"user_id"];
    STUserProfileViewController * userProfileVC = [STUserProfileViewController newControllerWithUserId:userId];
    [self.navigationController pushViewController:userProfileVC animated:YES];

}

- (IBAction)onTapShare:(id)sender {
    NSDictionary *dict = [self getCurrentDictionary];
    BOOL isOwner = [dict[@"is_owner"] boolValue];
    _shareOptionsView.shadowView.alpha = 0.0;
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.35f animations:^{
        [_shareOptionsView setUpForThreeButtons:!isOwner];
        _shareOptionsView.hidden=FALSE;
        _shareOptionsView.shadowView.alpha = 0.5;
        [_shareOptionsView setForDissmiss:NO];
    }];
    
}

- (IBAction)onSwipeLeftOnEdge:(id)sender {
    if (self.flowType == STFlowTypeHome) {
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
            if ([preLastCtrl isKindOfClass:[STUsersListController class]]||
                [preLastCtrl isKindOfClass:[STNotificationsViewController class]]) {
                [self.navigationController popToViewController:[viewCtrl objectAtIndex:viewCtrl.count-3] animated:YES];
            }
            else
                [self.navigationController popViewControllerAnimated:YES];
        }
       
    }
}

- (IBAction)onClickNearbyFromYouSawAllThePhotos:(id)sender {
    [[STMenuController sharedInstance] goNearby];
}
- (IBAction)onCLickInviteFriendsFromYouSawAllThePhotos:(id)sender {
    [self presentInterstitialControllerWithType:STInterstitialTypeInviter];
}

- (IBAction)onClickChatFromYouSawAllThePhotos:(id)sender {
    [self onChat:sender];
}

- (IBAction)onTapCameraUpload:(id)sender {
    
    NSDictionary * presentedPostDict = [self getCurrentDictionary];
    BOOL isOwner = YES;
    if (presentedPostDict[@"is_owner"]!=nil) {
        isOwner = [presentedPostDict[@"is_owner"] boolValue];
    }
    __weak STFlowTemplateViewController *weakSelf = self;
    imagePickerCompletion completion = ^(UIImage *img, BOOL shouldCompressImage){
        [weakSelf startMoveScaleShareControllerForImage:img shouldCompress:shouldCompressImage editedPostId:nil captionString:nil];

    };
    if (isOwner) {
        [[STImagePickerController sharedInstance] startImagePickerForOwnerInViewController:self withCompletion:completion];
    } else {
        [[STImagePickerController sharedInstance] startImagePickerInViewController:self withCompletion:completion andAskCompletion:^{
            [weakSelf inviteCurrentPostOwnerUserToUpload];
        }];
    }
}

- (IBAction)onTapLike:(id)sender {
#ifdef DEBUG
    [[STNotificationsManager sharedManager] handleInAppNotification:@{}];
#endif
    
    [(UIButton *)sender setUserInteractionEnabled:NO];
    NSArray *indxPats = [self.collectionView indexPathsForVisibleItems];
    if (indxPats.count ==0) {
        return;
    }
    __block NSInteger currentRow = [[indxPats objectAtIndex:0] row];
    __block NSMutableDictionary *cellDict = [NSMutableDictionary dictionaryWithDictionary:self.postsDataSource[currentRow]];

    __weak STFlowTemplateViewController *weakSelf = self;
    
    STRequestCompletionBlock completion = ^(id response, NSError *error){
        [(UIButton *)sender setUserInteractionEnabled:YES];
        
        if ([response[@"status_code"] integerValue]==STWebservicesSuccesCod) {
            
            STRequestCompletionBlock completion = ^(id response, NSError *error){
                if ([response[@"status_code"] integerValue]==STWebservicesSuccesCod) {
                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:response[@"data"]];
                    if (cellDict[@"post_seen"]!=nil) {
                        dict[@"post_seen"] = cellDict[@"post_seen"];
                    }
                    [weakSelf.postsDataSource replaceObjectAtIndex:currentRow
                                                        withObject:[NSDictionary dictionaryWithDictionary:dict]];
                    [weakSelf.collectionView performBatchUpdates:^{
                        STCustomCollectionViewCell *currentCell = [[weakSelf.collectionView visibleCells] firstObject];
                        if (currentCell != nil) {
                            [currentCell updateLikeBtnAndLblWithDict:dict];
                        }
                        //                        [weakSelf.collectionView reloadItemsAtIndexPaths:[weakSelf.collectionView indexPathsForVisibleItems]];
                    } completion:^(BOOL finished) {
                        BOOL isLiked = [cellDict[@"post_liked_by_current_user"] boolValue];
                        if (!isLiked && weakSelf.postsDataSource.count>currentRow+1) {
                            [weakSelf performSelector:@selector(goToNextPostWithRow:)
                                           withObject:@(currentRow+1)
                                           afterDelay:0.25f];
                            
                        }
                    }];
                }
            };
            [STGetPostDetailsRequest getPostDetails:cellDict[@"post_id"] withCompletion:completion failure:nil];

        }
    };
    
    STRequestFailureBlock failBlock = ^(NSError *error){
        [(UIButton *)sender setUserInteractionEnabled:YES];
    };
    
    [STSetPostLikeRequest setPostLikeForPostId:cellDict[@"post_id"]
                                withCompletion:completion
                                       failure:failBlock];
}
- (IBAction)onTapBigCameraProfile:(id)sender {
    switch (self.flowType) {
        case STFlowTypeMyGallery:{
            [self onTapCameraUpload:sender];
            break;
        }
        case STFlowTypeUserGallery:{
            [self inviteUserToUpload:_userID withUserName:_userName];
            break;
        }
            
        default:
            return;
            break;
    }
}
- (IBAction)onTapEditPost:(id)sender {
    STCustomCollectionViewCell *currentCell = (STCustomCollectionViewCell *)[[self.collectionView visibleCells] firstObject];
    [currentCell captionShadowPressed:nil];
    __block NSDictionary *currentDict = [self getCurrentDictionary];
    
    [[STImageCacheController sharedInstance] loadPostImageWithName:currentDict[@"full_photo_link"] withPostCompletion:^(UIImage *img) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        STSharePhotoViewController *viewController = (STSharePhotoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"shareScene"];
        viewController.imgData =UIImageJPEGRepresentation(img, 1.f);
        viewController.bluredImgData = UIImageJPEGRepresentation([img applyLightEffect], 1.f);
        viewController.delegate = self;
        viewController.captionString = currentDict[@"caption"];
        viewController.editPostId = currentDict[@"post_id"];
        viewController.controllerType = STShareControllerEditCaption;
        [self.navigationController pushViewController:viewController animated:YES];
        
        
    } andBlurCompletion:nil];

}
- (IBAction)onTapSeeMore:(id)sender {
    STCustomCollectionViewCell *currentCell = (STCustomCollectionViewCell *)[[self.collectionView visibleCells] firstObject];
    NSString *captionString = [[self getCurrentDictionary] valueForKey:@"caption"];
    if (captionString == nil || ![captionString isKindOfClass:[NSString class]]) {
        captionString = @"";
    }
    UIFont *font = [UIFont fontWithName:@"ProximaNova-Regular" size:14.f];
    UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];

    CGFloat textWidth = mainWindow.frame.size.width-kCaptionMarginOffset;
    CGRect rect = [captionString boundingRectWithSize:CGSizeMake(textWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    [self.collectionView performBatchUpdates:^{
        [currentCell addCaptionShadowWithExtraSpace:rect.size.height];
    } completion:nil];
}

- (void)inviteUserToUpload:(NSString *)userID withUserName:(NSString *)userName{
    STRequestCompletionBlock completion = ^(id response, NSError *error){
        NSInteger statusCode = [response[@"status_code"] integerValue];
        if (statusCode ==STWebservicesSuccesCod || statusCode == STWebservicesFounded) {
            NSString *message = [NSString stringWithFormat:@"Congrats, you%@ asked %@ to take a photo.We'll announce you when his new photo is on STATUS.",statusCode == STWebservicesSuccesCod?@"":@" already", userName];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:message delegate:self
                                                  cancelButtonTitle:@"OK" otherButtonTitles: nil];
            alert.tag = kInviteUserToUpload;
            [alert show];
        }
    };
    [STInviteUserToUploadRequest inviteUserToUpload:userID withCompletion:completion failure:nil];
}

- (void)inviteCurrentPostOwnerUserToUpload {
    
    NSDictionary * currentPostDict = [self getCurrentDictionary];
    NSString * userID = nil;
    NSString * userName = nil;
    if (currentPostDict == nil || currentPostDict[@"user_id"] == nil) {
        if (self.flowType == STFlowTypeUserGallery) {
            userID = _userID;
            userName = _userName;
        }
    }
    else{
        userID = currentPostDict[@"user_id"];
        userName = currentPostDict[@"user_name"];
    }

    if (userID == nil) {
        return;
    }
    
    [self inviteUserToUpload:userID withUserName:userName];
}

- (IBAction)onDismissShareOptions:(id)sender {
    [UIView animateWithDuration:0.35f animations:^{
        [_shareOptionsView setForDissmiss:YES];
        _shareOptionsView.shadowView.alpha = 0.0;
        [self.view layoutIfNeeded];
    }  completion:^(BOOL finished) {
        _shareOptionsView.hidden = TRUE;
    }];
}
- (IBAction)onSharePostToFacebook:(id)sender {
    [self sharePhotoOnFacebookWithImgUrl:[self getCurrentDictionary][@"full_photo_link"] andDescription:nil];
}

- (void)sharePhotoOnFacebookWithImgUrl:(NSString *)imgUrl andDescription:(NSString *)description{
    [[STFacebookHelper new] shareImageWithImageUrl:imgUrl description:description andCompletion:^(id result, NSError *error) {
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
    [[STImageCacheController sharedInstance] loadPostImageWithName:dict[@"full_photo_link"] withPostCompletion:^(UIImage *img) {
        if (img!=nil) {
            [weakSelf startMoveScaleShareControllerForImage:img shouldCompress:NO editedPostId:dict[@"post_id"] captionString:dict[@"caption"]];
        }
    } andBlurCompletion:nil];
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
        STRequestCompletionBlock completion = ^(id response, NSError *error){
            if ([response[@"status_code"] integerValue]==STWebservicesSuccesCod) {
                [[[UIAlertView alloc] initWithTitle:@"Report Post" message:@"A message was sent to the admin." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Report Post" message:@"This post was already reported." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }
        };
        
        [STRepostPostRequest reportPostWithId:dict[@"post_id"]
                               withCompletion:completion
                                      failure:nil];

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
    [[STImageCacheController sharedInstance] loadPostImageWithName:dict[@"full_photo_link"] withPostCompletion:^(UIImage *origImg) {
        completion(origImg);
        
    } andBlurCompletion:nil];
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
    [[_collectionView delegate] scrollViewWillBeginDragging:_collectionView];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:currentRow.integerValue inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionNone
                                            animated:YES];
    
    _shouldForceSetSeen = YES;
     [[_collectionView delegate] scrollViewDidEndDragging:_collectionView willDecelerate:YES];
}

#pragma mark - Collection View Data Source & Delegate

-(NSString *)identifierForCollectionView{
    if (_isDataSourceLoaded==YES&&_isPlaceholderSinglePost==YES) {
        return @"STNoPhotosCellIdentifier";
    }
    else
        return @"FlowCollectionCellIdentifier";
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = [self identifierForCollectionView];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
   
    cell.contentView.frame = cell.bounds;
    cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    

    if ([cell isKindOfClass:[STCustomCollectionViewCell class]]) {
        if (self.postsDataSource.count>indexPath.row) {
            NSDictionary *cellDict = self.postsDataSource[indexPath.row];
            [(STCustomCollectionViewCell *)cell setUpWithDictionary:cellDict forFlowType:_flowType];
        }
    }
    else if ([cell isKindOfClass:[STNoPhotosCell class]])
    {
        [(STNoPhotosCell *)cell setUpCellWithUserName:self.userName andFlow:_flowType];
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    _isPlaceholderSinglePost = NO;
    NSInteger numberOfItems = [self.postsDataSource count];
    
    switch (self.flowType) {
        case STFlowTypePopular:
        case STFlowTypeHome:
        case STFlowTypeRecent:
        case STFlowTypeDiscoverNearby:
            return numberOfItems;
            break;
        case STFlowTypeUserGallery:{
            if (numberOfItems > 0) {
                return numberOfItems;
            } else {
                _isPlaceholderSinglePost = YES;
                return 1; // there will be a placeholder post
            }
            break;
        }
        case STFlowTypeMyGallery:{
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

- (void)processLastPostWithIndex:(NSIndexPath *)indexPath {
    NSIndexPath *usedIndx = indexPath;
    if (usedIndx == nil) {
        usedIndx = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    if (usedIndx.row >= _postsDataSource.count) {
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self.postsDataSource objectAtIndex:usedIndx.row]];
    __weak STFlowTemplateViewController *weakSelf = self;
    if (self.flowType == STFlowTypePopular ||
        self.flowType == STFlowTypeRecent ||
        self.flowType == STFlowTypeHome) {
        if ([dict[@"post_seen"] boolValue] == TRUE) {
            return;
        }
        if (dict[@"post_id"] == nil) {
            return;
        }
        
        STRequestCompletionBlock completion = ^(id response, NSError *error){
            if ([response[@"status_code"] integerValue]==STWebservicesSuccesCod) {
                [weakSelf markDataSourceSeenAtIndex:usedIndx.row];
                BOOL shouldGetNextBatch = weakSelf.postsDataSource.count - usedIndx.row == kStartLoadOffset && usedIndx.row!=0;
                if (shouldGetNextBatch) {
                    [weakSelf getDataSourceWithOffset:weakSelf.postsDataSource.count - usedIndx.row - 1 + _numberOfDuplicates];
                }
            }
        };
        
        [STSetPostSeenRequest setPostSeen:dict[@"post_id"]
                           withCompletion:completion
                                  failure:nil];
    }
    else if(self.flowType != STFlowTypeSinglePost)
    {
        BOOL shouldGetNextBatch = _postsDataSource.count - usedIndx.row == kStartLoadOffset && usedIndx.row!=0;
        if (shouldGetNextBatch) {
            [self getDataSourceWithOffset:_postsDataSource.count+_numberOfDuplicates];
            
        }
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    _numberOfSeenPosts++;
//    [self presentInterstitialControllerForIndex:_numberOfSeenPosts];
    
    _end = scrollView.contentOffset;
    if (_start.x < _end.x || _shouldForceSetSeen == YES)
    {//swipe to the right
        _shouldForceSetSeen = NO;
        CGPoint point = scrollView.contentOffset;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        NSUInteger currentIndex = point.x/screenWidth;
        NSLog(@"CurrentIndex: %lu", (unsigned long)currentIndex);
        [self processLastPostWithIndex:[NSIndexPath indexPathForRow:currentIndex inSection:0]];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _start = scrollView.contentOffset;
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

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kDeletePostTag)
    {
        if (buttonIndex==1) {
            NSDictionary *dict = [self getCurrentDictionary];
            __weak STFlowTemplateViewController *weakSelf = self;
            STRequestCompletionBlock completion = ^(id response, NSError *error){
                if ([response[@"status_code"] integerValue] ==STWebservicesSuccesCod) {
                    //animate cell out
                    if (_flowType == STFlowTypeSinglePost) {
                        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                    }
                    else
                    {
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
                }
            };
            [STDeletePostRequest deletePost:dict[@"post_id"] withCompletion:completion failure:nil];
        }
    }
    else if (alertView.tag == kInviteUserToUpload){
        if (buttonIndex ==1) {
            [[STMenuController sharedInstance] goHome];
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

- (void)startMoveScaleShareControllerForImage:(UIImage *)img
                               shouldCompress:(BOOL)compressing
                                    editedPostId:(NSString *)postId
                                captionString:(NSString *)captionString{
    
    // here, no compressing should be done, because it might be a cropping after this
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    STMoveScaleViewController *viewController = (STMoveScaleViewController *)[storyboard instantiateViewControllerWithIdentifier:@"STMoveScaleViewController"];
    viewController.currentImg = img;
    viewController.delegate = self;
    viewController.editPostId = postId;
    viewController.shouldCompress = compressing;
    viewController.captionString = captionString;
    [self.navigationController pushViewController:viewController animated:NO];
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
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"likesSegue"]) {
        
        NSDictionary *dict = [self getCurrentDictionary];
        STUsersListController *viewController = (STUsersListController *)[segue destinationViewController];
        viewController.postId = dict[@"post_id"];
        viewController.controllerType = UsersListControllerTypeLikes;
    }
    else if ([segue.identifier isEqualToString:@"inviteSegue"]){
        [[STMenuController sharedInstance] hideMenu];
    }
}

@end

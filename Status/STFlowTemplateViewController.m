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
#import "STTopOption.h"
#import "STNotificationsViewController.h"
#import "STZoomablePostViewController.h"

int const kDeletePostTag = 11;
int const kTopOptionTag = 121;
int const kNoPostsAlertTag = 13;
@interface STFlowTemplateViewController ()<UICollectionViewDataSource, UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout, UIActionSheetDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UIAlertViewDelegate, FacebookControllerDelegate>
{
    STCustomShareView *_shareOptionsView;
    NSLayoutConstraint *_shareOptionsViewContraint;
    NSLayoutConstraint *_topOptionConstraint;
    NSDictionary *_lastNotif;
    BOOL _refresing;
    BOOL _pressedOnRefreshBth;
    UIButton *_refreshBtn;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *notifBtn;
@property (weak, nonatomic) IBOutlet UILabel *notifNumberLabel;

@property (strong, nonatomic) NSMutableArray *postsDataSource;

@end

@implementation STFlowTemplateViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.postsDataSource = [NSMutableArray array];
    if (self.flowType == STFlowTypeMyProfile) {
        [[STFacebookController sharedInstance] setLogoutDelegate:self];
    }
    else if (self.flowType == STFlowTypeAllPosts)
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
        if (self.flowType == STFlowTypeMyProfile)
            [self addTopOption];
    }

    [self setupVisuals];
    [self initCustomShareView];
    [self updateNotificationsNumber];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotificationsNumber) name:STNotificationBadgeValueDidChanged object:nil];
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) addTopOption{
    if (self.flowType == STFlowTypeMyProfile || self.flowType == STFlowTypeAllPosts) {
        if ([self.view viewWithTag:kTopOptionTag]==nil) {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"STTopOption" owner:self options:nil];
            STTopOption *topOption = (STTopOption *)[array objectAtIndex:0];
            [topOption initWithType: (self.flowType == STFlowTypeMyProfile)?STTopOptionTypeLogout:STTopOptionTypeUserProfile];
            [topOption setTag:kTopOptionTag];
            [topOption setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self.view addSubview:topOption];
            _topOptionConstraint =[NSLayoutConstraint
                                   constraintWithItem:topOption
                                   attribute:NSLayoutAttributeTop
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.topLayoutGuide
                                   attribute:NSLayoutAttributeTop
                                   multiplier:1.f
                                   constant:-91.f];
            
            [self.view addConstraints:@[_topOptionConstraint]];
        }
        
        else
        {
            STTopOption *topOption = (STTopOption *)[self.view viewWithTag:kTopOptionTag];
            [topOption updateBasicInfo];
        }
    }
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
    self.notifNumberLabel.layer.cornerRadius = 7;
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

#pragma mark - FacebookController Delegate

-(void)facebookControllerDidLoggedIn{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    [self addTopOption];
    self.postsDataSource = [NSMutableArray array];
    [self getDataSourceWithOffset:0];
    [self handleNotification:_lastNotif];
}

-(void)facebookControllerDidLoggedOut{
    [self onSwipeUp:nil];
    if (self.presentedViewController==nil) {
        [[STFacebookController sharedInstance] UDSetValue:nil forKey:PHOTO_LINK];
        [[STFacebookController sharedInstance] UDSetValue:nil forKey:USER_NAME];
        [[FBSession activeSession] close];
        [[FBSession activeSession] closeAndClearTokenInformation];
        [FBSession setActiveSession:nil];
        [[FBSessionTokenCachingStrategy defaultInstance] clearToken];
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self presentLoginScene];
        [[STWebServiceController sharedInstance] setAPNToken:@"" withCompletion:^(NSDictionary *response) {
            if ([response[@"status_code"] integerValue]==200)
                NSLog(@"APN Token deleted.");
            else  NSLog(@"APN token NOT deleted.");
        } orError:nil];
    }
}

#pragma mark - Get Data Source for Flow Type

- (void)getDataSourceWithOffset:(long) offset{
    NSLog(@"Offset: %ld", offset);
    __weak STFlowTemplateViewController *weakSelf = self;
    _refresing = TRUE;
    switch (self.flowType) {
        case STFlowTypeAllPosts:{
            [[STWebServiceController sharedInstance] getPostsWithOffset:offset withCompletion:^(NSDictionary *response) {
                
                if ([response[@"status_code"] integerValue] == STWebservicesSuccesCod) {
#if PAGGING_ENABLED
                    [weakSelf.postsDataSource addObjectsFromArray:response[@"data"]];
#else
                    weakSelf.postsDataSource = [NSMutableArray arrayWithArray:response[@"data"]];
#endif
                    [weakSelf.collectionView reloadData];
                    
                }
                _refresing = FALSE;
            } andErrorCompletion:^(NSError *error) {
                NSLog(@"error with %@", error.description);
                _refresing = FALSE;
            }];
            break;
        }
        case STFlowTypeMyProfile:
        case STFlowTypeUserProfile:{
            [[STWebServiceController sharedInstance] getUserPosts:self.userID withOffset:offset completion:^(NSDictionary *response) {
#if PAGGING_ENABLED
                [weakSelf.postsDataSource addObjectsFromArray:response[@"data"]];
#else
                weakSelf.postsDataSource = [NSMutableArray arrayWithArray:response[@"data"]];
#endif
                if (weakSelf.postsDataSource.count == 0) {
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"This user has no uploaded photos. You 'll be redirected to previous screen. " delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                    [alert setTag:kNoPostsAlertTag];
//                    [alert show];
                }
                else
                    [weakSelf.collectionView reloadData];
                
                _refresing = FALSE;
                
            } andErrorCompletion:^(NSError *error) {
                NSLog(@"error with %@", error.description);
                _refresing = FALSE;
            }];
            break;
        }
        case STFlowTypeSinglePost:{
            [[STWebServiceController sharedInstance] getPostDetails:self.postID withCompletion:^(NSDictionary *response) {
                weakSelf.postsDataSource = [NSMutableArray arrayWithObject:response[@"data"]];
                [weakSelf.collectionView reloadData];
            } andErrorCompletion:^(NSError *error) {
                
            }];
            break;
        }
        default:
            break;
    }
    //_refreshBtn.hidden = FALSE;
}

#pragma mark - Actions

- (void)updateNotificationsNumber{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [self setNotificationsNumber:app.badgeNumber];
}
- (IBAction)onPinchCurrentPost:(id)sender {
    
    //avoid apple bug on receiving this event twice
    if (self.navigationController.presentedViewController==nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        STZoomablePostViewController *viewController = (STZoomablePostViewController *) [storyboard instantiateViewControllerWithIdentifier:@"zoomableView"];
        NSDictionary *dict = [self getCurrentDictionary];
        viewController.postPhotoLink = dict[@"full_photo_link"];
        //[self.navigationController pushViewController:viewController animated:NO];
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
    [self onSwipeUp:nil];
    STFlowTemplateViewController *flowCtrl = [self.storyboard instantiateViewControllerWithIdentifier: @"flowTemplate"];
    flowCtrl.flowType = STFlowTypeMyProfile;
    flowCtrl.userID = [STFacebookController sharedInstance].currentUserId;
    [self.navigationController pushViewController:flowCtrl animated:YES];
}

- (IBAction)onTapShare:(id)sender {
    NSDictionary *dict = [self getCurrentDictionary];
    BOOL isOwner = [dict[@"is_owner"] boolValue];
    
    [UIView animateWithDuration:0.33f animations:^{
        [_shareOptionsView setUpForThreeButtons:isOwner?NO:YES];
        _shareOptionsView.hidden=FALSE;
        [_shareOptionsView setForDissmiss:NO];
        [self.view layoutIfNeeded];
        
    }];
    
}

- (IBAction)onSwipeDown:(id)sender {
    [UIView animateWithDuration:0.33f animations:^{
        //self.logOutButtonConstraint.constant = 7;
        _topOptionConstraint.constant = 0;
        [self.view layoutIfNeeded];
        
    }];
}
- (IBAction)onSwipeUp:(id)sender {
    [UIView animateWithDuration:0.33f animations:^{
        //self.logOutButtonConstraint.constant = -55;
        _topOptionConstraint.constant = -91;
        [self.view layoutIfNeeded];
        
    }];
}

- (IBAction)onTapBack:(id)sender {
    if (self.flowType == STFlowTypeAllPosts) {
        NSInteger currentRow = [[[self.collectionView indexPathsForVisibleItems] objectAtIndex:0] row];
        if (currentRow>0) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:currentRow-1 inSection:0]
                                        atScrollPosition:UICollectionViewScrollPositionNone
                                                animated:YES];
        }
        
    }
    else
    {
        NSArray *viewCtrl = self.navigationController.viewControllers;
        UIViewController *preLastCtrl = [viewCtrl objectAtIndex:viewCtrl.count-2];
        if ([preLastCtrl isKindOfClass:[STLikesViewController class]]||
            [preLastCtrl isKindOfClass:[STNotificationsViewController class]]) {
            [self.navigationController popToViewController:[viewCtrl objectAtIndex:viewCtrl.count-3] animated:YES];
        }
        else
            [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (IBAction)onTapCameraUpload:(id)sender {
    
    UIActionSheet *actionChoose = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Take a Photo",@"Open Camera Roll", nil];
    [actionChoose showFromRect: ((UIButton *)sender).frame inView:self.view animated:YES];
}

- (IBAction)onTapLike:(id)sender {
    __block NSInteger currentRow = [[[self.collectionView indexPathsForVisibleItems] objectAtIndex:0] row];
    __block NSMutableDictionary *cellDict = [NSMutableDictionary dictionaryWithDictionary:self.postsDataSource[currentRow]];

    __weak STFlowTemplateViewController *weakSelf = self;
    [[STWebServiceController sharedInstance] setPostLiked:cellDict[@"post_id"] withCompletion:^(NSDictionary *response) {
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
                    
                    
                }
            } andErrorCompletion:^(NSError *error) {
                
            }];
        }
        
    } orError:^(NSError *error) {
        
    }];
    BOOL isLiked = [cellDict[@"post_liked_by_current_user"] boolValue];
    if (!isLiked && weakSelf.postsDataSource.count>currentRow+1) {
        [weakSelf.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:currentRow+1 inSection:0]
                                        atScrollPosition:UICollectionViewScrollPositionNone
                                                animated:YES];
    }
}

- (IBAction)onDismissShareOptions:(id)sender {
    [UIView animateWithDuration:0.33f animations:^{
        [_shareOptionsView setForDissmiss:YES];
        [self.view layoutIfNeeded];
    }  completion:^(BOOL finished) {
        _shareOptionsView.hidden = TRUE;
    }];
}
- (IBAction)onSharePostToFacebook:(id)sender {
    [self getCurrentImageDataWithCompletion:^(UIImage *img) {
        NSData *imgData = UIImageJPEGRepresentation(img, 1.0);
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
    }];
}
- (IBAction)onSavePostLocally:(id)sender {
    [self getCurrentImageDataWithCompletion:^(UIImage *img) {
        UIImageWriteToSavedPhotosAlbum(img, self, @selector(thisImage:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), NULL);
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
    [[STImageCacheController sharedInstance] loadImageWithName:dict[@"full_photo_link"] andCompletion:^(UIImage *img) {
        completion(img);
    }];
}

-(NSDictionary *) getCurrentDictionary{
    if (self.postsDataSource==nil||self.postsDataSource.count==0) {
        return [NSDictionary dictionary];
    }
    NSArray *visibleInxPath = self.collectionView.indexPathsForVisibleItems;
    NSDictionary *dict = [self.postsDataSource objectAtIndex:[[visibleInxPath objectAtIndex:0] row]];
    
    return dict;
}

#pragma mark - Collection View Data Source & Delegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    STCustomCollectionViewCell *cell = (STCustomCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"FlowCollectionCellIdentifier" forIndexPath:indexPath];
    
    NSDictionary *cellDict = self.postsDataSource[indexPath.row];
    [cell setUpWithDictionary:cellDict forFlowType:self.flowType];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.postsDataSource count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.view.frame.size;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    // adding this BOOL to resolve the reloadData problem calling this function twice
    if (_refresing == TRUE) {
        return;
    }
    if (_pressedOnRefreshBth == TRUE) {
        _pressedOnRefreshBth = FALSE;
        return;
    }
#if PAGGING_ENABLED
    if (self.flowType == STFlowTypeAllPosts) {
        NSDictionary *dict = [self.postsDataSource objectAtIndex:indexPath.row];
        if ([dict[@"post_seen"] boolValue] == TRUE) {
            return;
        }
        __weak STFlowTemplateViewController *weakSelf = self;
        [[STWebServiceController sharedInstance] setPostSeen:dict[@"post_id"] withCompletion:^(NSDictionary *response) {
            if ([response[@"status_code"] integerValue]==STWebservicesSuccesCod) {
                [weakSelf markDataSourceSeenAtIndex:indexPath.row];
                int indexOffset = indexPath.row%POSTS_PAGGING;
                if (indexOffset == POSTS_PAGGING-2) {
                    [weakSelf getDataSourceWithOffset:POSTS_PAGGING-indexOffset-1];
                }
            }
            
        } orError:^(NSError *error) {
            NSLog(@"Post NOT set seen with error.");
        }];
    }
    else if(self.flowType != STFlowTypeSinglePost)
    {
        if (indexPath.row%POSTS_PAGGING == POSTS_PAGGING-2) {
            [self getDataSourceWithOffset:self.postsDataSource.count];
        }
    }
#endif
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                  withReuseIdentifier:@"footer"
                                                                                         forIndexPath:indexPath];
        
        _refreshBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 250, 100, 100)];
        [_refreshBtn setTitle:@"Refresh" forState:UIControlStateNormal];
        [_refreshBtn addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:_refreshBtn];

        if (self.postsDataSource.count == 0) {
            UIButton *addPhotoBt = [[UIButton alloc] initWithFrame:CGRectMake(20, 9, 40, 40)];
            [addPhotoBt setImage:[UIImage imageNamed:@"btn_camera_normal"] forState:UIControlStateNormal];
            [addPhotoBt setImage:[UIImage imageNamed:@"btn_camera_pressed"] forState:UIControlStateHighlighted];
            [addPhotoBt setImage:[UIImage imageNamed:@"btn_camera_pressed"] forState:UIControlStateSelected];
            [addPhotoBt setTag:100];
            [addPhotoBt addTarget:self action:@selector(onTapCameraUpload:) forControlEvents:UIControlEventTouchUpInside];
            [headerView addSubview:addPhotoBt];
        }
        else
            [[headerView viewWithTag:100] removeFromSuperview];
        
        reusableview = headerView;
    }
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    
    if (self.flowType == STFlowTypeSinglePost) {
        return CGSizeZero;
    }
    
    return CGSizeMake(100, 568);
}

-(void) refresh:(id) sender{
    _pressedOnRefreshBth = TRUE;
    if (self.flowType == STFlowTypeAllPosts) {
        [self getDataSourceWithOffset:1];
    }
    else
    {
        [self getDataSourceWithOffset:self.postsDataSource.count];
    }
    
}
-(void) markDataSourceSeenAtIndex:(long) index{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self.postsDataSource objectAtIndex:index]];
    [dict setValue:@(1) forKey:@"post_seen"];
    [self.postsDataSource replaceObjectAtIndex:index withObject:dict];
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex==2) return;
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

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kNoPostsAlertTag) {
        [self onTapBack:nil];
    }
    else if (alertView.tag == kDeletePostTag)
    {
        if (buttonIndex==1) {
            NSDictionary *dict = [self getCurrentDictionary];
            [[STWebServiceController sharedInstance] deletePost:dict[@"post_id"] withCompletion:^(NSDictionary *response) {
                
                if ([response[@"status_code"] integerValue] == STWebservicesSuccesCod) {
                    //animate cell out
                    [self.collectionView performBatchUpdates:^{
                        
                        NSArray *selectedItemsIndexPaths = [self.collectionView indexPathsForVisibleItems];
                        // Delete the items from the data source.
                        [self deleteItemsFromDataSourceAtIndexPaths:selectedItemsIndexPaths];
                        // Now delete the items from the collection view.
                        [self.collectionView deleteItemsAtIndexPaths:selectedItemsIndexPaths];
                        
                    } completion:nil];
                }
                
            } orError:^(NSError *error) {
                NSLog(@"POST NOT DELETED: %@", error);
            }];
            
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

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSData *data = UIImageJPEGRepresentation(img, 0.25);
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        STSharePhotoViewController *viewController = (STSharePhotoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"shareScene"];
        viewController.imgData = data;
        [self.navigationController pushViewController:viewController animated:NO];
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
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

#pragma mark - Helper

-(void) handleNotification:(NSDictionary *) notif{
    if (notif!=nil) {
        [self setNotificationsNumber:[notif[@"aps"][@"badge"] integerValue]];
    }
    if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[STFlowTemplateViewController class]]) {
        
        if ([STWebServiceController sharedInstance].accessToken == nil) {
            //wait for the login to be performed and after handle the notification
            _lastNotif = notif;
        }
        else if (_lastNotif !=nil || notif !=nil)
        {
            _lastNotif = nil;
            [self performSegueWithIdentifier:@"notifSegue" sender:nil];
        }
    }
    
}
@end

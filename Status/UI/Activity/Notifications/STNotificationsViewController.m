//
//  STNotificationsViewController.m
//  Status
//
//  Created by Cosmin Andrus on 3/5/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STNotificationsViewController.h"
#import "STNetworkQueueManager.h"
#import "STConstants.h"
#import "STNotificationCell.h"
#import "STSmartNotificationCell.h"
#import "STTopNotificationCell.h"
#import "STMyTopNotificationCell.h"
#import "AppDelegate.h"
#import "STLoginService.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+Mask.h"
#import "NSDate+Additions.h"
#import "STGetNotificationsRequest.h"
#import "STUsersListController.h"
#import "UIImage+Resize.h"

#import "NSString+MD5.h"

#import "ContainerFeedVC.h"
#import "STNavigationService.h"
#import "STNotificationsManager.h"
#import "STDataAccessUtils.h"
#import "STNotificationObj.h"
#import "STFollowDataProcessor.h"
#import "STListUser.h"
#import "STLocalNotificationService.h"

#import "STFlowProcessor.h"
#import "STShareTopViewControler.h"

const float kNoNotifHeight = 24.f;

@interface STNotificationsViewController ()<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
{
    UIImage *timeIconImage;
    
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noNotificationViewHeightConstr;
@property (weak, nonatomic) IBOutlet UITableView *notificationTable;
@property (strong, nonatomic) UITapGestureRecognizer * tapOnRow;
@property (nonatomic, strong) STFollowDataProcessor *followProcessor;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSArray *notificationDataSource;

@property (nonatomic, strong) NSArray <NSNumber *> *smartNotifications;
@property (nonatomic, strong) NSArray <NSNumber *> *topNotifications;

@end

@implementation STNotificationsViewController

+ (STNotificationsViewController *)newController{
    UIStoryboard * mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    STNotificationsViewController *notifController = [mainStoryboard instantiateViewControllerWithIdentifier: @"notificationScene"];

    return notifController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.smartNotifications = [STNotificationObj smartNotifications];
    self.topNotifications = [STNotificationObj topNotifications];
    
    self.navigationController.hidesBarsOnTap = NO;
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"ACTIVITY";
    timeIconImage =  [[UIImage imageNamed:@"chat time icon"] resizedImage:CGSizeMake(10.f, 10.f) interpolationQuality:kCGInterpolationMedium];
    // add gesture recognizer to use instead of didSelectRowAtIndexPath
    _tapOnRow = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    _tapOnRow.numberOfTapsRequired = 1;
    _tapOnRow.numberOfTouchesRequired = 1;
    [self.notificationTable addGestureRecognizer:_tapOnRow];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldGoToTop:) name:STNotificationShouldGoToTop object:nil];
    
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, 30.f);
    
    _refreshControl = [[UIRefreshControl alloc] initWithFrame:rect];
    [_refreshControl addTarget:self action:@selector(refreshControlChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.notificationTable addSubview:_refreshControl];
    [_refreshControl beginRefreshing];
    _noNotificationViewHeightConstr.constant = 0.f;
    _notificationTable.hidden = NO;
    [_notificationTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self.view layoutIfNeeded];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.hidesBarsOnSwipe = NO;
    self.navigationController.navigationBarHidden = NO;
    [self getNotificationsFromServer];
}

-(void)refreshControlChanged:(UIRefreshControl*)sender{
    NSLog(@"Value changed: %@", @(sender.refreshing));
    [self getNotificationsFromServer];
}

-(void) getNotificationsFromServer{
    if (![CoreManager loggedIn] ||
        [CoreManager isGuestUser]) {
        return;
    }
    __weak STNotificationsViewController *weakSelf = self;
    
    [STDataAccessUtils getNotificationsWithCompletion:^(NSArray *objects, NSError *error) {
        __strong STNotificationsViewController *strongSelf = weakSelf;
        strongSelf.notificationDataSource = [NSArray arrayWithArray:objects];
        [strongSelf.notificationTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        if (strongSelf.refreshControl.refreshing) {
            [strongSelf.refreshControl endRefreshing];
        }
        if (!error) {
            BOOL shouldShowPlaceholder = strongSelf.notificationDataSource.count == 0;
            if (shouldShowPlaceholder) {
                strongSelf.noNotificationViewHeightConstr.constant = strongSelf.view.frame.size.height;
            }else{
                strongSelf.noNotificationViewHeightConstr.constant = 0;
            }
            strongSelf.notificationTable.hidden = shouldShowPlaceholder;
            [strongSelf.notificationTable reloadData];
        }
        else
        {
            strongSelf.noNotificationViewHeightConstr.constant = strongSelf.view.frame.size.height;
            strongSelf.notificationTable.hidden = YES;
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    _notificationTable.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

#pragma mark - IBAction

- (IBAction)onClickback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onStartExploringPressed:(id)sender {
    [[CoreManager navigationService] switchToTabBarAtIndex:STTabBarIndexExplore
                                               popToRootVC:YES];
}

#pragma mark - Hook Methods

-(BOOL)shouldHideLeftButton{
    return YES;
}


#pragma mark Notification

- (void) shouldGoToTop:(NSNotification *)notif{
    BOOL animated = [notif.userInfo[kAnimatedTabBarKey] boolValue];
    [self.notificationTable setContentOffset:CGPointZero animated:animated];
}

#pragma mark - DidSelectedNotification

- (void)handleTap:(id)sender {
    if (sender != _tapOnRow) {
        return;
    }
    
    CGPoint pointOfTapInTableView = [_tapOnRow locationInView:self.notificationTable];
    NSIndexPath * indexPathOfSelectedRow = [self.notificationTable indexPathForRowAtPoint:pointOfTapInTableView];
    
    if (_notificationDataSource == nil || _notificationDataSource.count == 0) {
        return;
    }
    
    STNotificationObj *no = _notificationDataSource[indexPathOfSelectedRow.row];
    STNotificationType notificationType = no.type;

    if ([self.smartNotifications containsObject:@(notificationType)]) {
        switch (notificationType) {
            case STNotificationTypePhotosWaiting:
                //go to main feed
                [[CoreManager navigationService] switchToTabBarAtIndex:STTabBarIndexHome
                                                           popToRootVC:YES];
                break;
            case STNotificationTypeNewUserJoinsStatus:
                //go to user profile
                [self onTapUserNameOrUserProfilePictureAtIndexPath:indexPathOfSelectedRow];
                break;
            case STNotificationTypeGuaranteedViewsForNextPhoto:
            case STNotificationType5DaysUploadNewPhoto:
            {
                [[CoreManager navigationService] switchToTabBarAtIndex:STTabBarIndexTakeAPhoto popToRootVC:YES];
                
            }
                break;
            default:
                break;
        }
        
    }else if ([self.topNotifications containsObject:@(notificationType)]){
        if (notificationType == STNotificationTypeTop) {
            //get the top_id and present the top feed
            NSString *topId = no.topId;
            if (topId) {
                STFlowProcessor *topProcessor = [[STFlowProcessor alloc] initWithFlowType:STFlowTypeTop topId:topId];
                ContainerFeedVC *vc = [ContainerFeedVC feedControllerWithFlowProcessor:topProcessor];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }else if (notificationType == STNotificationTypeShareTop){
            STMyTopNotificationCell * cell = (STMyTopNotificationCell *)[self.notificationTable cellForRowAtIndexPath:indexPathOfSelectedRow];
            CGPoint pointOfTapInCell = [_tapOnRow locationInView:cell.contentView];
            STMyNotificationRegionType tapType = [cell regionForPointOfTap:pointOfTapInCell];
            if (tapType == STMyNotificationRegionTypePostRelated) {
                [self onTapPostPictureAtIndexPath:indexPathOfSelectedRow];
            }else{
                NSLog(@"go to share top screen");
                STShareTopViewControler *vc = [STShareTopViewControler shareTopViewControllerWithNotification:no];
                [self.navigationController presentViewController:vc animated:YES completion:nil];
//                [self.navigationController pushViewController:vc animated:YES];

            }

        }
    }else{
        STNotificationCell * cell = (STNotificationCell *)[self.notificationTable cellForRowAtIndexPath:indexPathOfSelectedRow];
        CGPoint pointOfTapInCell = [_tapOnRow locationInView:cell.contentView];
        switch ([cell regionForPointOfTap:pointOfTapInCell]) {
            case STNotificationRegionTypeUserRelated:
                [self onTapUserNameOrUserProfilePictureAtIndexPath:indexPathOfSelectedRow];
                break;
            case STNotificationRegionTypePostRelated:
                [self onTapPostPictureAtIndexPath:indexPathOfSelectedRow];
                break;
                
            default:
                break;
        }

    }
}

- (void)onTapUserNameOrUserProfilePictureAtIndexPath:(NSIndexPath *)indexPath {
    STNotificationObj *no = [_notificationDataSource objectAtIndex:indexPath.row];
    STNotificationType notifType = no.type;
    
    switch (notifType) {
        case STNotificationTypeInvite:
            [[CoreManager navigationService] switchToTabBarAtIndex:STTabBarIndexTakeAPhoto popToRootVC:YES];
            break;
        default:
        {
            ContainerFeedVC *feedCVC = [ContainerFeedVC galleryFeedControllerForUserId:no.userId andUserName:nil];
            [self.navigationController pushViewController:feedCVC animated:YES];
        }
            break;
    }
}

- (void)onTapPostPictureAtIndexPath:(NSIndexPath *)indexPath {
    
    __block STNotificationObj *no = [_notificationDataSource objectAtIndex:indexPath.row];
    STNotificationType notifType = no.type;
    
    switch (notifType) {
        case STNotificationTypeLike:
        case STNotificationTypeUploaded:
        case STNotificationTypeShareTop:
        {
            
            ContainerFeedVC *feedCVC = [ContainerFeedVC singleFeedControllerWithPostId:no.postId];
            [self.navigationController pushViewController:feedCVC animated:YES];
        }
            break;
        case STNotificationTypeInvite:
        {
            
            ContainerFeedVC *feedCVC = [ContainerFeedVC galleryFeedControllerForUserId:no.userId andUserName:nil];
            [self.navigationController pushViewController:feedCVC animated:YES];
        }
            break;
        case STNotificationTypeGotFollowed:
        {
            STListUser *listUser = [no listUserFromNotification];
            _followProcessor = [[STFollowDataProcessor alloc] initWithUsers:@[listUser]];
            
            listUser.followedByCurrentUser = @(![listUser.followedByCurrentUser boolValue]);
            
            __weak STNotificationsViewController * weakSelf = self;
            
            [_followProcessor uploadDataToServer:@[listUser]
                                  withCompletion:^(NSError *error) {
                                      __strong STNotificationsViewController *strongSelf = weakSelf;
                                      if (error == nil) {//success
                                          no.followed = !no.followed;
                                          [strongSelf.notificationTable reloadData];
                                          [[CoreManager localNotificationService] postNotificationName:STHomeFlowShouldBeReloadedNotification object:nil userInfo:nil];
                                      }
                                  }];
        }
            break;
            
        default:
        {
            
            ContainerFeedVC *feedCVC = [ContainerFeedVC singleFeedControllerWithPostId:no.userId];
            [self.navigationController pushViewController:feedCVC animated:YES];
        }
            break;
    }
}

#pragma mark - UITableView Delegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    STNotificationObj *no = [_notificationDataSource objectAtIndex:indexPath.row];
    STNotificationType notificationType = no.type;
    STNotificationBaseCell *cell = nil;

    if ([self.smartNotifications containsObject:@(notificationType)]) {
        //smart notifications, generated by server
        cell = (STSmartNotificationCell *)[tableView dequeueReusableCellWithIdentifier:@"smartNotificationCell"];
        STSmartNotificationCell *actualCell = (STSmartNotificationCell *)cell;
        [actualCell configureWithNotificationObject:no];
    }else if ([self.topNotifications containsObject:@(notificationType)]){
        //top notifications, generated by server
        if (notificationType == STNotificationTypeShareTop) {
            cell = (STMyTopNotificationCell *)[self.notificationTable dequeueReusableCellWithIdentifier:@"myTopNotificationCell"];
            [(STMyTopNotificationCell *)cell configureWithNotificationObject:no];

        }else{
            cell = (STTopNotificationCell *)[self.notificationTable dequeueReusableCellWithIdentifier:@"topNotificationCell"];
            [(STTopNotificationCell *)cell configureWithNotificationObject:no];
        }

    }else{
        // normal notifications (user generated notifications)
        cell = (STNotificationCell *)[tableView dequeueReusableCellWithIdentifier:@"notificationCell"];
        STNotificationCell *actualCell = (STNotificationCell *)cell;
        [actualCell configureWithNotificationObject:no];

    }
    return cell;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _notificationDataSource.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - UIGestureRecognizer delegate method

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == _tapOnRow) {
        CGPoint pointOfTap = [gestureRecognizer locationInView:gestureRecognizer.view];
        if ([self.notificationTable indexPathForRowAtPoint:pointOfTap]) {
            return YES;
        }
        return NO;
    }
    
    return YES;
}

#pragma mark - Disable and Enable scrolling

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
    
    if ([_containeeDelegate respondsToSelector:@selector(containeeStartedScrolling)]) {
        [_containeeDelegate containeeStartedScrolling];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([_containeeDelegate respondsToSelector:@selector(containeeEndedScrolling)]) {
        [_containeeDelegate containeeEndedScrolling];
    }
}

#pragma mark - STSideBySideConatinerProtocol

- (void)containerEndedScrolling {
    _notificationTable.scrollEnabled = YES;
}

- (void)containerStartedScrolling {
    _notificationTable.scrollEnabled = NO;
}

@end

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
#import "STImageCacheController.h"
#import "AppDelegate.h"
#import "STFacebookLoginController.h"
#import "UIImageView+WebCache.h"
#import "NSDate+Additions.h"
#import "STGetNotificationsRequest.h"
#import "STUsersListController.h"

#import "STUserProfileViewController.h"

#import "NSString+MD5.h"

#import "FeedCVC.h"
#import "STNavigationService.h"
#import "STNotificationsManager.h"
#import "STDataAccessUtils.h"
#import "STNotificationObj.h"

const float kNoNotifHeight = 24.f;

@interface STNotificationsViewController ()<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
{
    NSArray *_notificationDataSource;
}
@property (weak, nonatomic) IBOutlet UILabel *noNotifLabel;
@property (weak, nonatomic) IBOutlet UITableView *notificationTable;
@property (strong, nonatomic) UITapGestureRecognizer * tapOnRow;
@end

@implementation STNotificationsViewController

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
    
    // add gesture recognizer to use instead of didSelectRowAtIndexPath
    _tapOnRow = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    _tapOnRow.numberOfTapsRequired = 1;
    _tapOnRow.numberOfTouchesRequired = 1;
    [self.notificationTable addGestureRecognizer:_tapOnRow];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getNotificationsFromServer];
}

-(void) getNotificationsFromServer{
    if (![CoreManager loggedIn]) {
        return;
    }
    __weak STNotificationsViewController *weakSelf = self;
    
    [STDataAccessUtils getNotificationsWithCompletion:^(NSArray *objects, NSError *error) {
        _notificationDataSource = [NSArray arrayWithArray:objects];
        if (!error) {
            BOOL shouldShowPlaceholder = _notificationDataSource.count > 0;
            weakSelf.noNotifLabel.hidden = shouldShowPlaceholder;
            
            [[CoreManager notificationsService] setOverAllBadgeNumber:0];
            [weakSelf.notificationTable reloadData];
        }
        else
            weakSelf.noNotifLabel.hidden = NO;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    _notificationTable.delegate = nil;
}
- (IBAction)onClickback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
    
    STNotificationCell * cell = (STNotificationCell *)[self.notificationTable cellForRowAtIndexPath:indexPathOfSelectedRow];
    CGPoint pointOfTapInCell = [_tapOnRow locationInView:cell.contentView];
    if ([cell isKindOfClass:[STNotificationCell class]]) {
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
    else if ([cell isKindOfClass:[STSmartNotificationCell class]]){
        STNotificationObj *no = _notificationDataSource[indexPathOfSelectedRow.row];
        STNotificationType notificationType = no.type;
        
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
                [[CoreManager navigationService] switchToTabBarAtIndex:STTabBarIndexTakAPhoto popToRootVC:YES];

            }
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
            [[CoreManager navigationService] switchToTabBarAtIndex:STTabBarIndexTakAPhoto popToRootVC:YES];
            break;
        default:
        {
            STUserProfileViewController * profileVC = [STUserProfileViewController newControllerWithUserId:no.userId];
            profileVC.shouldOpenCameraRoll = (notifType == STNotificationTypeInvite);
            [self.navigationController pushViewController:profileVC animated:YES];
        }
            break;
    }
}

- (void)onTapPostPictureAtIndexPath:(NSIndexPath *)indexPath {
    
    STNotificationObj *no = [_notificationDataSource objectAtIndex:indexPath.row];
    STNotificationType notifType = no.type;
    
    switch (notifType) {
        case STNotificationTypeLike:
        case STNotificationTypeUploaded:
        {
            
            FeedCVC *feedCVC = [FeedCVC singleFeedControllerWithPostId:no.postId];
            [self.navigationController pushViewController:feedCVC animated:YES];
        }
            break;
        case STNotificationTypeInvite:
        {
            
            STUserProfileViewController * profileVC = [STUserProfileViewController newControllerWithUserId:no.userId];
            [self.navigationController pushViewController:profileVC animated:YES];
            
        }
            break;
        case STNotificationTypeGotFollowed:
        {
            STUsersListController * newVC = [STUsersListController newControllerWithUserId:no.userId postID:nil andType:UsersListControllerTypeFollowers];
            [self.navigationController pushViewController:newVC animated:YES];
        }
            break;
            
        default:
        {
            
            FeedCVC *feedCVC = [FeedCVC singleFeedControllerWithPostId:no.userId];
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

    if (notificationType < STNotificationTypeChatMessage || notificationType == STNotificationTypeGotFollowed) {
        // normal notifications (user generated notifications)
        cell = (STNotificationCell *)[tableView dequeueReusableCellWithIdentifier:@"notificationCell"];
        STNotificationCell *actualCell = (STNotificationCell *)cell;
        [actualCell.postImg sd_setImageWithURL:[NSURL URLWithString:no.postPhotoUrl]];
        [actualCell.userImg sd_setImageWithURL:[NSURL URLWithString:no.userThumbnail]];
        actualCell.isSeen = no.seen;
        actualCell.messageLbl.text = [NSString stringWithFormat:@"%@", no.message];
        actualCell.timeLbl.text = [NSDate notificationTimeIntervalSinceDate:no.date];
        actualCell.notificationTypeMessage.text = [self getNotificationTypeStringForType:notificationType];
        actualCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {   //smart notifications, generated by server
        cell = (STSmartNotificationCell *)[tableView dequeueReusableCellWithIdentifier:@"smartNotificationCell"];
        STSmartNotificationCell *actualCell = (STSmartNotificationCell *)cell;
        NSString *postPhotoLink = no.postPhotoUrl;
        if (postPhotoLink.length == 0) {
            actualCell.userImg.image = [UIImage imageNamed:@"logo"];
        }
        else
            [actualCell.userImg sd_setImageWithURL:[NSURL URLWithString:postPhotoLink]];
        actualCell.seenCircle.hidden = no.seen;
        actualCell.timeLbl.text = [NSDate notificationTimeIntervalSinceDate:no.date];
        if (notificationType == STNotificationTypeNewUserJoinsStatus) {
            NSString *string = [NSString stringWithFormat:@"%@ is on STATUS. Say hello :)", no.userName];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
            UIFont *boldFont = [UIFont fontWithName:@"ProximaNova-Semibold" size:13.f];
            NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                   boldFont, NSFontAttributeName,nil];

            [attributedString setAttributes:attrs range:NSMakeRange(0, [no.userName length])];
            actualCell.notificationTypeMessage.attributedText = attributedString;
        }
        else
            actualCell.notificationTypeMessage.text = no.message;
        actualCell.selectionStyle = UITableViewCellSelectionStyleNone;

        
    }
    return cell;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _notificationDataSource.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - Helper

-(NSString *) getNotificationTypeStringForType:(STNotificationType)type{
    NSString *str = @"";
    switch (type) {
        case STNotificationTypeLike:
            str = @"likes your photo.";
            break;
        case STNotificationTypeInvite:
            str = @"asked you to upload a photo.";
            break;
        case STNotificationTypeUploaded:
            str = @"uploaded a photo.";
            break;
        case STNotificationTypeGotFollowed:
            str = @"is following you.";
            break;
        default:
#ifdef DEBUG
            str = @"CHANGE THIS MOCKUP TEXT.";
#else
            str = @"likes your photo.";
#endif
            break;
    }
    
    return str;
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

- (void)containerEndedScrolling {
    _notificationTable.scrollEnabled = YES;
}

- (void)containerStartedScrolling {
    _notificationTable.scrollEnabled = NO;
}

@end

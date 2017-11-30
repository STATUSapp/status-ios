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
#import "UIImageView+Mask.h"
#import "NSDate+Additions.h"
#import "STGetNotificationsRequest.h"
#import "STUsersListController.h"
#import "UIImage+Resize.h"

#import "NSString+MD5.h"

#import "FeedCVC.h"
#import "STNavigationService.h"
#import "STNotificationsManager.h"
#import "STDataAccessUtils.h"
#import "STNotificationObj.h"
#import "STFollowDataProcessor.h"
#import "STListUser.h"
#import "STLocalNotificationService.h"
#import "ContainerFeedVC.h"

const float kNoNotifHeight = 24.f;

@interface STNotificationsViewController ()<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
{
    UIImage *timeIconImage;
    
}
@property (weak, nonatomic) IBOutlet UILabel *noNotifLabel;
@property (weak, nonatomic) IBOutlet UITableView *notificationTable;
@property (strong, nonatomic) UITapGestureRecognizer * tapOnRow;
@property (nonatomic, strong) STFollowDataProcessor *followProcessor;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSArray *notificationDataSource;

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
    
    self.view.backgroundColor = [UIColor clearColor];
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
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getNotificationsFromServer];
}

-(void)refreshControlChanged:(UIRefreshControl*)sender{
    NSLog(@"Value changed: %@", @(sender.refreshing));
    [self getNotificationsFromServer];
}

-(void) getNotificationsFromServer{
    if (![CoreManager loggedIn]) {
        return;
    }
    __weak STNotificationsViewController *weakSelf = self;
    
    [STDataAccessUtils getNotificationsWithCompletion:^(NSArray *objects, NSError *error) {
        weakSelf.notificationDataSource = [NSArray arrayWithArray:objects];
        if (weakSelf.refreshControl.refreshing) {
            [weakSelf.refreshControl endRefreshing];
        }
        if (!error) {
            BOOL shouldShowPlaceholder = _notificationDataSource.count > 0;
            weakSelf.noNotifLabel.hidden = shouldShowPlaceholder;
            weakSelf.notificationTable.hidden = !shouldShowPlaceholder;
            [weakSelf.notificationTable reloadData];
        }
        else
        {
            weakSelf.noNotifLabel.hidden = NO;
            weakSelf.notificationTable.hidden = YES;
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

- (IBAction)onClickback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
                [[CoreManager navigationService] switchToTabBarAtIndex:STTabBarIndexTakeAPhoto popToRootVC:YES];

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
        {
            
            FeedCVC *feedCVC = [FeedCVC singleFeedControllerWithPostId:no.postId];
            feedCVC.shouldAddBackButton = YES;
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
                                      if (error == nil) {//success
                                          no.followed = !no.followed;
                                          [weakSelf.notificationTable reloadData];
                                          [[CoreManager localNotificationService] postNotificationName:STHomeFlowShouldBeReloadedNotification object:nil userInfo:nil];
                                      }
                                  }];
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

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 2.f;

    if (notificationType < STNotificationTypeChatMessage || notificationType == STNotificationTypeGotFollowed) {
        // normal notifications (user generated notifications)
        cell = (STNotificationCell *)[tableView dequeueReusableCellWithIdentifier:@"notificationCell"];
        STNotificationCell *actualCell = (STNotificationCell *)cell;
        [actualCell.userImg sd_setImageWithURL:[NSURL URLWithString:no.userThumbnail] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [actualCell.userImg maskImage:image];
        }];
        if (notificationType!=STNotificationTypeGotFollowed) {
            [actualCell.postImg sd_setImageWithURL:[NSURL URLWithString:no.postPhotoUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image) {
                    actualCell.rightImageWidthConstraint.constant = 38.f;
                }
                else
                    actualCell.rightImageWidthConstraint.constant = 0.f;
                
            }];
        }
        else
        {
            actualCell.rightImageWidthConstraint.constant = 38.f;
            UIImage *image = nil;
            if (no.followed == YES) {
                image = [UIImage imageNamed:@"following icon"];
            }
            else
                image = [UIImage imageNamed:@"follow icon"];
            
            actualCell.postImg.image = image;
        }

        NSString *timeString = [[NSDate notificationTimeIntervalSinceDate:no.date] lowercaseString];
        NSMutableAttributedString *detailsString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",no.message, timeString]];
        
        UIFont *nameFont = [UIFont fontWithName:@"ProximaNova-Bold" size:15.f];
        UIFont *messageFont = [UIFont fontWithName:@"ProximaNova-Regular" size:15.f];
        NSRange nameRange = [no.message rangeOfString:no.userName];
        NSRange messageRange = NSMakeRange(0, detailsString.string.length);
        NSRange timeRange = [detailsString.string rangeOfString:timeString];
        
        if (nameRange.location != NSNotFound) {
            [detailsString addAttribute:NSFontAttributeName value:nameFont range:nameRange];
            messageRange.location = nameRange.location + nameRange.length;
            messageRange.length-=(nameRange.length + nameRange.location);
        }
        [detailsString addAttribute:NSFontAttributeName value:messageFont range:messageRange];

        if (timeRange.location != NSNotFound) {
            UIColor *grayColor = [UIColor colorWithRed:178.f/255.f
                                                 green:178.f/255.f
                                                  blue:178.f/255.f
                                                 alpha:1.f];
            
            [detailsString addAttribute:NSForegroundColorAttributeName value:grayColor range:timeRange];
            [detailsString addAttribute:NSFontAttributeName value:messageFont range:timeRange];

        }
        
        [detailsString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, detailsString.string.length)];

        /*
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        textAttachment.image = timeIconImage;
        NSAttributedString *timeIconString = [NSAttributedString attributedStringWithAttachment:textAttachment];
        
        [detailsString insertAttributedString:timeIconString atIndex:no.message.length + 1];
        */
        actualCell.messageLbl.attributedText = detailsString;
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
        if (notificationType == STNotificationTypeNewUserJoinsStatus) {
            NSString *string = [NSString stringWithFormat:@"%@ is on STATUS. Say hello :)", no.userName];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
            UIFont *boldFont = [UIFont fontWithName:@"ProximaNova-Bold" size:15.f];
            NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                   boldFont, NSFontAttributeName,nil];

            [attributedString setAttributes:attrs range:NSMakeRange(0, [no.userName length])];
            actualCell.messageLbl.attributedText = attributedString;
        }
        else
            actualCell.messageLbl.text = no.message;
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

#pragma mark - STSideBySideConatinerProtocol

- (void)containerEndedScrolling {
    _notificationTable.scrollEnabled = YES;
}

- (void)containerStartedScrolling {
    _notificationTable.scrollEnabled = NO;
}

@end

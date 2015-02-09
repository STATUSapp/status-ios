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
#import "STFlowTemplateViewController.h"
#import "STFacebookLoginController.h"
#import "UIImageView+WebCache.h"
#import "NSDate+Additions.h"
#import "STGetNotificationsRequest.h"

#import "STUserProfileViewController.h"

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
    if ([STNetworkQueueManager sharedManager].accessToken == nil) {
        return;
        //TODO: we should find a solution for this case
    }
    __weak STNotificationsViewController *weakSelf = self;
    STRequestCompletionBlock completion = ^(id response, NSError *error){
        if ([response[@"status_code"] integerValue]==STWebservicesSuccesCod) {
            _notificationDataSource = [NSArray arrayWithArray:response[@"data"]];
            BOOL shouldShowPlaceholder = _notificationDataSource.count > 0;
            weakSelf.noNotifLabel.hidden = shouldShowPlaceholder;
            
            [(AppDelegate *)[UIApplication sharedApplication].delegate setBadgeNumber:0];
            [weakSelf.notificationTable reloadData];
        }
        else
            weakSelf.noNotifLabel.hidden = NO;
    };
    STRequestFailureBlock failBlock = ^(NSError *error){
        weakSelf.noNotifLabel.hidden = NO;
    };

    [STGetNotificationsRequest getNotificationsWithCompletion:completion failure:failBlock];
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
        NSDictionary *dict = _notificationDataSource[indexPathOfSelectedRow.row];
        NSInteger notificationType = [dict[@"type"] integerValue];
        
        switch (notificationType) {
            case STNotificationTypePhotosWaiting:
                //go to main feed
                [self.navigationController popToRootViewControllerAnimated:YES];
                break;
            case STNotificationTypeNewUserJoinsStatus:
                //go to user profile
                [self onTapUserNameOrUserProfilePictureAtIndexPath:indexPathOfSelectedRow];
                break;
            case STNotificationTypeGuaranteedViewsForNextPhoto:
            case STNotificationType5DaysUploadNewPhoto:
            {
                //go to main feed with camera button pressed
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                UINavigationController *navController = (UINavigationController *)window.rootViewController;
                STFlowTemplateViewController *viewController = (STFlowTemplateViewController *)[navController.viewControllers firstObject];
                viewController.shouldActionCameraBtn = YES;
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
                break;
            default:
                break;
        }
    }
}

- (void)onTapUserNameOrUserProfilePictureAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = [_notificationDataSource objectAtIndex:indexPath.row];
    STNotificationType notifType = [dict[@"type"] integerValue];
    
    
    switch (notifType) {
            
        default:
        {
            //TODO: TEST THIS
            STUserProfileViewController * profileVC = [STUserProfileViewController newControllerWithUserId:dict[@"post_id"]];
            [self.navigationController pushViewController:profileVC animated:YES];
        }
            break;
    }
}

- (void)onTapPostPictureAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dict = [_notificationDataSource objectAtIndex:indexPath.row];
    STNotificationType notifType = [dict[@"type"] integerValue];
    
    switch (notifType) {
        case STNotificationTypeLike:{
            STFlowTemplateViewController *flowCtrl = [self.storyboard instantiateViewControllerWithIdentifier: @"flowTemplate"];
            flowCtrl.flowType = STFlowTypeSinglePost;
            flowCtrl.postID = dict[@"post_id"];
            flowCtrl.userID = dict[@"user_id"];
            flowCtrl.userName = dict[@"user_name"];
            [self.navigationController pushViewController:flowCtrl animated:YES];
        }
            break;
        case STNotificationTypeInvite:
        {
            //TODO: TEST THIS
            STUserProfileViewController * profileVC = [STUserProfileViewController newControllerWithUserId:dict[@"post_id"]];
            [self.navigationController pushViewController:profileVC animated:YES];
            
        }
            break;
        case STNotificationTypeUploaded:
        {
            
            //TODO: TEST THIS
            STUserProfileViewController * profileVC = [STUserProfileViewController newControllerWithUserId:dict[@"post_id"]];
            [self.navigationController pushViewController:profileVC animated:YES];
        }
            break;
            
        default:
        {
            STFlowTemplateViewController *flowCtrl = [self.storyboard instantiateViewControllerWithIdentifier: @"flowTemplate"];
            flowCtrl.flowType = STFlowTypeSinglePost;
            flowCtrl.postID = dict[@"post_id"];
            flowCtrl.userID = dict[@"user_id"];
            flowCtrl.userName = dict[@"user_name"];
            [self.navigationController pushViewController:flowCtrl animated:YES];
        }
            break;
    }
}

#pragma mark - UITableView Delegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict = [_notificationDataSource objectAtIndex:indexPath.row];
    NSInteger notificationType = [dict[@"type"] integerValue];
    STNotificationBaseCell *cell = nil;

    if (notificationType < STNotificationTypeChatMessage) {
        // normal notifications (user generated notifications)
        cell = (STNotificationCell *)[tableView dequeueReusableCellWithIdentifier:@"notificationCell"];
        STNotificationCell *actualCell = (STNotificationCell *)cell;
        [actualCell.postImg sd_setImageWithURL:[NSURL URLWithString:dict[@"post_photo_link"]]];
        [actualCell.userImg sd_setImageWithURL:[NSURL URLWithString:dict[@"user_photo_link"]]];
        actualCell.seenCircle.hidden = [dict[@"seen"] boolValue];
        actualCell.messageLbl.text = [NSString stringWithFormat:@"%@", dict[@"user_name"]];
        actualCell.timeLbl.text = [NSDate notificationTimeIntervalSinceDate:[ NSDate dateFromServerDate:dict[@"date"]]];
        actualCell.notificationTypeMessage.text = [self getNotificationTypeStringForType:notificationType];
        actualCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {   //smart notifications, generated by server
        cell = (STSmartNotificationCell *)[tableView dequeueReusableCellWithIdentifier:@"smartNotificationCell"];
        STSmartNotificationCell *actualCell = (STSmartNotificationCell *)cell;
        NSString *postPhotoLink = dict[@"user_photo_link"];
        if (postPhotoLink.length == 0) {
            actualCell.userImg.image = [UIImage imageNamed:@"logo"];
        }
        else
            [actualCell.userImg sd_setImageWithURL:[NSURL URLWithString:postPhotoLink]];
        actualCell.seenCircle.hidden = [dict[@"seen"] boolValue];
        actualCell.timeLbl.text = [NSDate notificationTimeIntervalSinceDate:[ NSDate dateFromServerDate:dict[@"date"]]];
        if (notificationType == STNotificationTypeNewUserJoinsStatus) {
            NSString *string = [NSString stringWithFormat:@"%@ is on STATUS. Say hello :)", dict[@"user_name"]];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
            UIFont *boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.f];
            NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                   boldFont, NSFontAttributeName,nil];

            [attributedString setAttributes:attrs range:NSMakeRange(0, [dict[@"user_name"] length])];
            actualCell.notificationTypeMessage.attributedText = attributedString;
        }
        else
            actualCell.notificationTypeMessage.text = dict[@"message"];
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

@end

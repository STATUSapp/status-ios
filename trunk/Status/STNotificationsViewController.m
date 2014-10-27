//
//  STNotificationsViewController.m
//  Status
//
//  Created by Cosmin Andrus on 3/5/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STNotificationsViewController.h"
#import "STWebServiceController.h"
#import "STConstants.h"
#import "STNotificationCell.h"
#import "STImageCacheController.h"
#import "AppDelegate.h"
#import "STFlowTemplateViewController.h"
#import "STFacebookController.h"
#import "UIImageView+WebCache.h"

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
    [self getNotificationsFromServer];
}

-(void) getNotificationsFromServer{
    __weak STNotificationsViewController *weakSelf = self;
	[[STWebServiceController sharedInstance] getNotificationsWithCompletion:^(NSDictionary *response) {
        if ([response[@"status_code"] integerValue] == STWebservicesSuccesCod) {
            _notificationDataSource = [NSArray arrayWithArray:response[@"data"]];
            weakSelf.noNotifLabel.hidden = _notificationDataSource.count>0;
            
            [(AppDelegate *)[UIApplication sharedApplication].delegate setBadgeNumber:0];            
            [weakSelf.notificationTable reloadData];
        }
        
    } andErrorCompletion:^(NSError *error) {
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

#pragma mark - Date Helper

- (NSString *)notificationTimeIntervalSinceDate: (NSDate *)dateOfNotification{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:dateOfNotification];
    
    if (0 <= timeInterval && timeInterval <= 60) {
        return @"JUST NOW";
    }
    int mins = timeInterval / 60;
    if (mins <= 60) {
        return [NSString stringWithFormat:@" %d MIN%@", mins, (mins==1)?@"":@"S"];
    }
    int hours = timeInterval / 3600;
    if (hours <= 24) {
        return [NSString stringWithFormat:@" %d HR%@", hours, (hours==1)?@"":@"S"];
    }
    
    if (timeInterval / 3600 <= 48) {
        return @"YESTERDAY";
    }
    
    return [NSString stringWithFormat:@"%d DAYS", (int)(timeInterval / 86400)];
}

-(NSDate *) dateFromServerDate:(NSString *) serverDate{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    NSDate *resultDate = [dateFormatter dateFromString:serverDate];
    return resultDate;
}

#pragma mark - DidSelectedNotification

- (void)handleTap:(id)sender {
    if (sender != _tapOnRow) {
        return;
    }
    
    CGPoint pointOfTapInTableView = [_tapOnRow locationInView:self.notificationTable];
    NSIndexPath * indexPathOfSelectedRow = [self.notificationTable indexPathForRowAtPoint:pointOfTapInTableView];
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

- (void)onTapUserNameOrUserProfilePictureAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = [_notificationDataSource objectAtIndex:indexPath.row];
    STNotificationType notifType = [dict[@"type"] integerValue];
    
    switch (notifType) {
            
        default:
        {
            STFlowTemplateViewController *flowCtrl = [self.storyboard instantiateViewControllerWithIdentifier: @"flowTemplate"];
            flowCtrl.flowType = STFlowTypeUserProfile;
            flowCtrl.userID = dict[@"user_id"];
            flowCtrl.userName = dict[@"user_name"];
            [self.navigationController pushViewController:flowCtrl animated:YES];
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
            STFlowTemplateViewController *flowCtrl = [self.storyboard instantiateViewControllerWithIdentifier: @"flowTemplate"];
            flowCtrl.flowType = STFlowTypeMyProfile;
            flowCtrl.userID = [STFacebookController sharedInstance].currentUserId;
            flowCtrl.userName = [[STFacebookController sharedInstance] getUDValueForKey:USER_NAME];
            [self.navigationController pushViewController:flowCtrl animated:YES];
        }
            break;
        case STNotificationTypeUploaded:
        {
            STFlowTemplateViewController *flowCtrl = [self.storyboard instantiateViewControllerWithIdentifier: @"flowTemplate"];
            flowCtrl.flowType = STFlowTypeUserProfile;
            flowCtrl.userID = dict[@"user_id"];
            [self.navigationController pushViewController:flowCtrl animated:YES];
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
    STNotificationCell *cell = (STNotificationCell *)[tableView dequeueReusableCellWithIdentifier:@"notificationCell"];
    [cell.postImg sd_setImageWithURL:[NSURL URLWithString:dict[@"post_photo_link"]]];
    [cell.userImg sd_setImageWithURL:[NSURL URLWithString:dict[@"user_photo_link"]]];
    cell.seenCircle.hidden = [dict[@"seen"] boolValue];
    cell.messageLbl.text = [NSString stringWithFormat:@"%@", dict[@"user_name"]];
    cell.timeLbl.text = [self notificationTimeIntervalSinceDate:[ self dateFromServerDate:dict[@"date"]]];
    cell.notificationTypeMessage.text = [self getNotificationTypeStringForType:notificationType];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (notificationType < STNotificationTypeChatMessage) {
        // normal notifications (user generated notifications)
    }
    else
    {
        //smart notifications, generated by server
        
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSDictionary *dict = [_notificationDataSource objectAtIndex:indexPath.row];
//    STNotificationType notifType = [dict[@"type"] integerValue];
//    
//    switch (notifType) {
//        case STNotificationTypeLike:{
//            STFlowTemplateViewController *flowCtrl = [self.storyboard instantiateViewControllerWithIdentifier: @"flowTemplate"];
//            flowCtrl.flowType = STFlowTypeSinglePost;
//            flowCtrl.postID = dict[@"post_id"];
//            flowCtrl.userID = dict[@"user_id"];
//            flowCtrl.userName = dict[@"user_name"];
//            [self.navigationController pushViewController:flowCtrl animated:YES];
//        }
//            break;
//        case STNotificationTypeInvite:
//        {
//            STFlowTemplateViewController *flowCtrl = [self.storyboard instantiateViewControllerWithIdentifier: @"flowTemplate"];
//            flowCtrl.flowType = STFlowTypeMyProfile;
//            flowCtrl.userID = [STFacebookController sharedInstance].currentUserId;
//            flowCtrl.userName = [[STFacebookController sharedInstance] getUDValueForKey:USER_NAME];
//            [self.navigationController pushViewController:flowCtrl animated:YES];
//        }
//            break;
//        case STNotificationTypeUploaded:
//        {
//            STFlowTemplateViewController *flowCtrl = [self.storyboard instantiateViewControllerWithIdentifier: @"flowTemplate"];
//            flowCtrl.flowType = STFlowTypeUserProfile;
//            flowCtrl.userID = dict[@"user_id"];
//            [self.navigationController pushViewController:flowCtrl animated:YES];
//        }
//            break;
//            
//        default:
//        {
//            STFlowTemplateViewController *flowCtrl = [self.storyboard instantiateViewControllerWithIdentifier: @"flowTemplate"];
//            flowCtrl.flowType = STFlowTypeSinglePost;
//            flowCtrl.postID = dict[@"post_id"];
//            flowCtrl.userID = dict[@"user_id"];
//            flowCtrl.userName = dict[@"user_name"];
//            [self.navigationController pushViewController:flowCtrl animated:YES];
//        }
//            break;
//    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _notificationDataSource.count;
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

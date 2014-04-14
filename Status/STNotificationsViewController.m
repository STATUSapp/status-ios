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

const float kNoNotifHeight = 24.f;

@interface STNotificationsViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSArray *_notificationDataSource;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noNotifHeight;
@property (weak, nonatomic) IBOutlet UITableView *notificationTable;
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
    _noNotifHeight.constant = 0.f;
}

-(void)viewWillAppear:(BOOL)animated{
    __weak STNotificationsViewController *weakSelf = self;
	[[STWebServiceController sharedInstance] getNotificationsWithCompletion:^(NSDictionary *response) {
        if ([response[@"status_code"] integerValue] == STWebservicesSuccesCod) {
            _notificationDataSource = [NSArray arrayWithArray:response[@"data"]];
            
            _noNotifHeight.constant = _notificationDataSource.count>0?0.f:kNoNotifHeight;
            
            [(AppDelegate *)[UIApplication sharedApplication].delegate setBadgeNumber:0];
            [[NSNotificationCenter defaultCenter] postNotificationName:STNotificationBadgeValueDidChanged object:nil];
            
            [weakSelf.notificationTable reloadData];
        }
        
    } andErrorCompletion:^(NSError *error) {
        _noNotifHeight.constant = _notificationDataSource.count>0?0.f:kNoNotifHeight;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


#pragma mark - UITableView Delegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    STNotificationCell *cell = (STNotificationCell *)[tableView dequeueReusableCellWithIdentifier:@"notificationCell"];
    NSDictionary *dict = [_notificationDataSource objectAtIndex:indexPath.row];
    [[STImageCacheController sharedInstance] loadImageWithName:dict[@"post_photo_link"]
                                                 andCompletion:^(UIImage *img) {
                                                     cell.postImg.image = img;
                                                 }];
    [[STImageCacheController sharedInstance] loadImageWithName:dict[@"user_photo_link"]
                                                 andCompletion:^(UIImage *img) {
                                                     cell.userImg.image = img;
                                                 }];
    cell.seenCircle.hidden = [dict[@"seen"] boolValue];
    cell.messageLbl.text = [NSString stringWithFormat:@"%@", dict[@"user_name"]];
    cell.timeLbl.text = [self notificationTimeIntervalSinceDate:[ self dateFromServerDate:dict[@"date"]]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict = [_notificationDataSource objectAtIndex:indexPath.row];
    STFlowTemplateViewController *flowCtrl = [self.storyboard instantiateViewControllerWithIdentifier: @"flowTemplate"];
    flowCtrl.flowType = STFlowTypeSinglePost;
    flowCtrl.postID = dict[@"post_id"];
    flowCtrl.userID = dict[@"user_id"];
    flowCtrl.userName = dict[@"user_name"];
    [self.navigationController pushViewController:flowCtrl animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _notificationDataSource.count;
}

@end

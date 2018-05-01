//
//  STLikesViewController.m
//  Status
//
//  Created by Cosmin Andrus on 3/4/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STUsersListController.h"
#import "STNetworkQueueManager.h"
#import "STUserListCell.h"
#import "STImageCacheController.h"
#import "STFacebookLoginController.h"
#import "STChatRoomViewController.h"
#import "STChatController.h"
#import "UIImageView+WebCache.h"
#import "ContainerFeedVC.h"

#import "STDataAccessUtils.h"
#import "STDataModelObjects.h"
#import "STFollowDataProcessor.h"
#import "STLocalNotificationService.h"
#import "UIImageView+Mask.h"

@interface STUsersListController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray * dataSource;
@property (strong, nonatomic) STFollowDataProcessor * dataProcessor;

@end

@implementation STUsersListController

+ (instancetype)newControllerWithUserId:(NSString *)userID postID:(NSString *)postID andType:(UsersListControllerType)type {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    STUsersListController * newController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([STUsersListController class])];
    newController.postId = postID;
    newController.userId = userID;
    newController.controllerType = type;
    
    return newController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setTitleLabel {
    NSString *title = @"";
    switch (self.controllerType) {
        case UsersListControllerTypeFollowers:
            title = @"Followers";
            break;
        case UsersListControllerTypeFollowing:
            title = @"Following";
            break;
        case UsersListControllerTypeLikes:
            title = @"Likes";
            break;
            
        default:
            break;
    }
    self.title = title;
}

- (void)getDataSource {
    __weak STUsersListController *weakSelf = self;
    switch (self.controllerType) {
        case UsersListControllerTypeFollowers:{
            [STDataAccessUtils getFollowersForUserId:_userId offset:@(_dataSource.count) withCompletion:^(NSArray *objects, NSError *error) {
                
                if (weakSelf.dataSource == nil) {
                    weakSelf.dataSource = [NSMutableArray arrayWithArray:objects];
                } else {
                    [weakSelf.dataSource addObjectsFromArray:objects];
                }
                weakSelf.dataProcessor = [[STFollowDataProcessor alloc] initWithUsers:weakSelf.dataSource];
                [weakSelf.tableView reloadData];
            }];
        }
            break;
        case UsersListControllerTypeFollowing:{
            [STDataAccessUtils getFollowingForUserId:_userId offset:@(_dataSource.count) withCompletion:^(NSArray *objects, NSError *error) {
                if (weakSelf.dataSource == nil) {
                    weakSelf.dataSource = [NSMutableArray arrayWithArray:objects];
                } else {
                    [weakSelf.dataSource addObjectsFromArray:objects];
                }
                weakSelf.dataProcessor = [[STFollowDataProcessor alloc] initWithUsers:weakSelf.dataSource];
                [weakSelf.tableView reloadData];
            }];
        }
            break;
        case UsersListControllerTypeLikes:{
            [STDataAccessUtils getLikesForPostId:_postId withCompletion:^(NSArray *objects, NSError *error) {
                if (weakSelf.dataSource == nil) {
                    weakSelf.dataSource = [NSMutableArray arrayWithArray:objects];
                } else {
                    [weakSelf.dataSource addObjectsFromArray:objects];
                }
                weakSelf.dataProcessor = [[STFollowDataProcessor alloc] initWithUsers:weakSelf.dataSource];
                [weakSelf.tableView reloadData];
            }];
        }
            break;
            
        default:
            break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self setTitleLabel];
    [self getDataSource];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.hidesBarsOnSwipe = NO;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [_dataProcessor uploadDataToServer:_dataSource
                        withCompletion:^(NSError *error) {
                            [[CoreManager localNotificationService] postNotificationName:STHomeFlowShouldBeReloadedNotification object:nil userInfo:nil];
                        }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    _tableView.delegate = nil;
}

#pragma mark - IBActions
- (IBAction)onClickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onFollowUnfollowButtonPressed:(id)sender {
    NSInteger index = [(UIButton *)sender tag];
    STListUser *lu = [_dataSource objectAtIndex:index];
    lu.followedByCurrentUser = @(!lu.followedByCurrentUser.boolValue);
    [_tableView reloadData];
}
//- (IBAction)onChatWithUser:(id)sender {
//    if (![[STChatController sharedInstance] canChat]) {
//        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Chat connection appears to be offline right now. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
////#ifndef DEBUG
//        return;
////#endif
//    }
//    STListUser *lu = _dataSource[((UIButton *)sender).tag];
//    STChatRoomViewController *viewController = [STChatRoomViewController roomWithUser:lu];
//    [self.navigationController pushViewController:viewController animated:YES];
//}

#pragma mark - UITableView Delegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    STListUser *lu = [_dataSource objectAtIndex:indexPath.row];
    STUserListCell *cell = (STUserListCell *)[tableView dequeueReusableCellWithIdentifier:@"STUserListCell"];
    [cell.userPhoto sd_setImageWithURL:[NSURL URLWithString:lu.thumbnail] placeholderImage:[UIImage imageNamed:[lu genderImage]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            [cell.userPhoto maskImage:image];
        }
    }];
   
    cell.userName.text = lu.userName;
//    cell.chatButton.tag = cell.followBtn.tag = indexPath.row;
    cell.followBtn.selected = [lu.followedByCurrentUser boolValue];
    cell.followBtn.tag = indexPath.row;
    //not use message appVersion since there is a problem for some users
//    NSString *appVersion = lu.appVersion;
    if (/*appVersion == nil ||
        ![appVersion isKindOfClass:[NSString class]] ||
        [appVersion rangeOfString:@"1.0."].location == NSNotFound ||*/
        [[[CoreManager loginService] currentUserUuid] isEqualToString:lu.uuid]) {//not setted
//        cell.chatButton.hidden = YES;
        cell.followBtn.hidden = YES;
    }
    else
    {
//        cell.chatButton.hidden = NO;
        cell.followBtn.hidden = NO;
    }
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        
    STListUser *lu = [_dataSource objectAtIndex:indexPath.row];
    ContainerFeedVC *feedCVC = [ContainerFeedVC galleryFeedControllerForUserId:lu.uuid andUserName:lu.userName];
    [self.navigationController pushViewController:feedCVC animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}
@end

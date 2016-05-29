//
//  STLikesViewController.m
//  Status
//
//  Created by Cosmin Andrus on 3/4/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STUsersListController.h"
#import "STNetworkQueueManager.h"
#import "STLikeCell.h"
#import "STImageCacheController.h"
#import "STFacebookLoginController.h"
#import "STChatRoomViewController.h"
#import "STChatController.h"
#import "UIImageView+WebCache.h"

#import "STUserProfileViewController.h"
#import "STDataAccessUtils.h"
#import "STDataModelObjects.h"
#import "STFollowDataProcessor.h"

@interface STUsersListController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

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
    switch (self.controllerType) {
        case UsersListControllerTypeFollowers:
            self.lblTitle.text = @"Followers";
            break;
        case UsersListControllerTypeFollowing:
            self.lblTitle.text = @"Following";
            break;
        case UsersListControllerTypeLikes:
            self.lblTitle.text = @"Likes";
            break;
            
        default:
            break;
    }
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
                weakSelf.dataProcessor = [[STFollowDataProcessor alloc] initWithUsers:_dataSource];
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
                weakSelf.dataProcessor = [[STFollowDataProcessor alloc] initWithUsers:_dataSource];
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
                weakSelf.dataProcessor = [[STFollowDataProcessor alloc] initWithUsers:_dataSource];
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

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [_dataProcessor uploadDataToServer:_dataSource
                        withCompletion:nil];
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
- (IBAction)onChatWithUser:(id)sender {
//    if (![[STChatController sharedInstance] canChat]) {
//        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Chat connection appears to be offline right now. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
////#ifndef DEBUG
//        return;
////#endif
//    }
    STListUser *lu = _dataSource[((UIButton *)sender).tag];
    STChatRoomViewController *viewController = [STChatRoomViewController roomWithUser:lu];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UITableView Delegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    STListUser *lu = [_dataSource objectAtIndex:indexPath.row];
    STLikeCell *cell = (STLikeCell *)[tableView dequeueReusableCellWithIdentifier:@"likeCell"];
    [cell.userPhoto sd_setImageWithURL:[NSURL URLWithString:lu.thumbnail]];
   
    cell.userName.text = lu.userName;
    cell.chatButton.tag = cell.followBtn.tag = indexPath.row;
    cell.followBtn.selected = [lu.followedByCurrentUser boolValue];
    
    //not use message appVersion since there is a problem for some users
//    NSString *appVersion = lu.appVersion;
    if (/*appVersion == nil ||
        ![appVersion isKindOfClass:[NSString class]] ||
        [appVersion rangeOfString:@"1.0."].location == NSNotFound ||*/
        [[[CoreManager loginService] currentUserUuid] isEqualToString:lu.uuid]) {//not setted
        cell.chatButton.hidden = YES;
    }
    else
        cell.chatButton.hidden = NO;
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        
    STListUser *lu = [_dataSource objectAtIndex:indexPath.row];
    STUserProfileViewController * profileVC = [STUserProfileViewController newControllerWithUserId:lu.uuid];
    [self.navigationController pushViewController:profileVC animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}
@end

//
//  STLikesViewController.m
//  Status
//
//  Created by Cosmin Andrus on 3/4/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STLikesViewController.h"
#import "STNetworkQueueManager.h"
#import "STLikeCell.h"
#import "STImageCacheController.h"
#import "STFlowTemplateViewController.h"
#import "STFacebookLoginController.h"
#import "STChatRoomViewController.h"
#import "STChatController.h"
#import "UIImageView+WebCache.h"

#import "STUserProfileViewController.h"
#import "STDataAccessUtils.h"
#import "STDataModelObjects.h"
#import "STFollowDataProcessor.h"

@interface STLikesViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *_likesDataSource;
    STFollowDataProcessor *_dataProcessor;
}
@property (weak, nonatomic) IBOutlet UITableView *likesTableView;

@end

@implementation STLikesViewController

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
    __weak STLikesViewController *weakSelf = self;
    
    [STDataAccessUtils getLikesForPostId:_postId withCompletion:^(NSArray *objects, NSError *error) {
        _likesDataSource = [NSMutableArray arrayWithArray:objects];
        _dataProcessor = [[STFollowDataProcessor alloc] initWithUsers:objects];
        [weakSelf.likesTableView reloadData];
    }];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [_dataProcessor uploadDataToServer:_likesDataSource
                        withCompletion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    _likesTableView.delegate = nil;
}

#pragma mark - IBActions
- (IBAction)onClickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onFollowUnfollowButtonPressed:(id)sender {
    NSInteger index = [(UIButton *)sender tag];
    STLikeUser *lu = [_likesDataSource objectAtIndex:index];
    lu.followedByCurrentUser = @(!lu.followedByCurrentUser.boolValue);
    [_likesTableView reloadData];
}
- (IBAction)onChatWithUser:(id)sender {
//    if (![[STChatController sharedInstance] canChat]) {
//        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Chat connection appears to be offline right now. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
////#ifndef DEBUG
//        return;
////#endif
//    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatScene" bundle:nil];
    STChatRoomViewController *viewController = (STChatRoomViewController *)[storyboard instantiateViewControllerWithIdentifier:@"chat_room"];
    STLikeUser *lu = _likesDataSource[((UIButton *)sender).tag];
    viewController.userInfo = [NSMutableDictionary dictionaryWithDictionary:lu.infoDict];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UITableView Delegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    STLikeUser *lu = [_likesDataSource objectAtIndex:indexPath.row];
    STLikeCell *cell = (STLikeCell *)[tableView dequeueReusableCellWithIdentifier:@"likeCell"];
    [cell.userPhoto sd_setImageWithURL:[NSURL URLWithString:lu.thumbnail]];
   
    cell.userName.text = lu.userName;
    cell.chatButton.tag = cell.followBtn.tag = indexPath.row;
    cell.followBtn.selected = [lu.followedByCurrentUser boolValue];
    NSString *appVersion = lu.appVersion;
    if (appVersion == nil ||
        ![appVersion isKindOfClass:[NSString class]] ||
        [appVersion rangeOfString:@"1.0."].location == NSNotFound ||
        [[STFacebookLoginController sharedInstance].currentUserId isEqualToString:lu.uuid]) {//not setted
        cell.chatButton.hidden = YES;
    }
    else
        cell.chatButton.hidden = NO;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        
    STLikeUser *lu = [_likesDataSource objectAtIndex:indexPath.row];
    STUserProfileViewController * profileVC = [STUserProfileViewController newControllerWithUserId:lu.uuid];
    [self.navigationController pushViewController:profileVC animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _likesDataSource.count;
}
@end

//
//  STLikesViewController.m
//  Status
//
//  Created by Cosmin Andrus on 3/4/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STLikesViewController.h"
#import "STWebServiceController.h"
#import "STLikeCell.h"
#import "STImageCacheController.h"
#import "STFlowTemplateViewController.h"
#import "STFacebookController.h"
#import "STChatRoomViewController.h"
#import "STChatController.h"
#import "UIImageView+WebCache.h"

@interface STLikesViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSArray *_likesDataSource;
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
	[[STWebServiceController sharedInstance] getPostLikes:self.postId withCompletion:^(NSDictionary *response) {
        _likesDataSource = [NSArray arrayWithArray:response[@"data"]];
        [weakSelf.likesTableView reloadData];
    } andErrorCompletion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions
- (IBAction)onClickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onChatWithUser:(id)sender {
    if (![[STChatController sharedInstance] canChat]) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Chat connection appears to be offline right now. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
//#ifndef DEBUG
        return;
//#endif
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatScene" bundle:nil];
    STChatRoomViewController *viewController = (STChatRoomViewController *)[storyboard instantiateViewControllerWithIdentifier:@"chat_room"];
    viewController.userInfo = [NSMutableDictionary dictionaryWithDictionary:_likesDataSource[((UIButton *)sender).tag]];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UITableView Delegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict = [_likesDataSource objectAtIndex:indexPath.row];
    STLikeCell *cell = (STLikeCell *)[tableView dequeueReusableCellWithIdentifier:@"likeCell"];
#if !USE_SD_WEB
    [[STImageCacheController sharedInstance] loadImageWithName:dict[@"full_photo_link"]
                                                 andCompletion:^(UIImage *img) {
                                                     cell.userPhoto.image = img;
                                                 } isForFacebook:NO];
#else
    [cell.userPhoto sd_setImageWithURL:[NSURL URLWithString:dict[@"full_photo_link"]]];
#endif
   
    cell.userName.text = dict[@"user_name"];
    cell.chatButton.tag = indexPath.row;
    
    NSString *appVersion = dict[@"app_version"];
    if (appVersion == nil ||
        ![appVersion isKindOfClass:[NSString class]] ||
        [appVersion rangeOfString:@"1.0."].location == NSNotFound ||
        [[STFacebookController sharedInstance].currentUserId isEqualToString:dict[@"user_id"]]) {//not setted
        cell.chatButton.hidden = YES;
    }
    else
        cell.chatButton.hidden = NO;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dict = [_likesDataSource objectAtIndex:indexPath.row];
    STFlowTemplateViewController *flowCtrl = [self.storyboard instantiateViewControllerWithIdentifier: @"flowTemplate"];
    flowCtrl.flowType = STFlowTypeUserProfile;
    flowCtrl.userID = dict[@"user_id"];
    flowCtrl.userName = dict[@"user_name"];
    if ([flowCtrl.userID isEqualToString:[STFacebookController sharedInstance].currentUserId ]) {
        flowCtrl.flowType = STFlowTypeMyProfile;
    }
    [self.navigationController pushViewController:flowCtrl animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _likesDataSource.count;
}
@end

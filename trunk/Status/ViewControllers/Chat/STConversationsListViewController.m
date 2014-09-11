//
//  STConversationsListViewController.m
//  Status
//
//  Created by Silviu on 01/06/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STConversationsListViewController.h"
#import "STConversationCell.h"
#import "STWebServiceController.h"
#import "STChatRoomViewController.h"
#import "STFacebookController.h"
#import "STChatController.h"
#import "STImageCacheController.h"
#import "UIImageView+Mask.h"

@interface STConversationsListViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    NSString *_allUsersSearchText;
    NSMutableArray *_allUsersArray;
    
    NSString *_nearbySearchText;
    NSMutableArray *_nearbyUsers;
    
    NSString *_recentSearchtext;
    NSMutableArray *_recentUsers;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UIButton *loadMoreButton;

@end

@implementation STConversationsListViewController

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
    _allUsersArray = [NSMutableArray new];
    _nearbyUsers = [NSMutableArray new];
    _recentUsers = [NSMutableArray new];
   
}

-(void)viewWillAppear:(BOOL)animated{
    [self loadNewDataWithOffset:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView datasource and delegate methods

-(NSDictionary *)getDictionaryorIndex:(NSInteger)index{
    NSArray *currentArray = nil;
    switch (_segment.selectedSegmentIndex) {
        case STSearchControlAll:
            currentArray = _allUsersArray;
            break;
        case STSearchControlNearby:
            currentArray = _nearbyUsers;
            break;
            
        case STSearchControlRecent:
            currentArray = _recentUsers;
            break;
    }
    if (currentArray.count>index) {
        return currentArray[index];
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numRows = 0;
    switch (_segment.selectedSegmentIndex) {
        case STSearchControlAll:
            numRows = _allUsersArray.count;
            break;
        case STSearchControlNearby:
           numRows = _nearbyUsers.count;
            break;
            
        case STSearchControlRecent:
            numRows = _recentUsers.count;
            break;
    }
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STConversationCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([STConversationCell class])];
    NSDictionary *dict = [self getDictionaryorIndex:indexPath.row];
    NSString *imageUrl = dict[@"small_photo_link"];
    if (![imageUrl isEqual:[NSNull null]]) {
#if !USE_SD_WEB
        [[STImageCacheController sharedInstance] loadImageWithName:imageUrl andCompletion:^(UIImage *img) {
            [cell.profileImageView maskImage:img];
        } isForFacebook:NO];
        
#else
        [[STImageCacheController sharedInstance] loadImageWithName:imageUrl andCompletion:^(UIImage *img) {
            [cell.profileImageView maskImage:img];
        }];
        
#endif
    }
    BOOL isUnread = ![dict[@"message_read"] boolValue];
    NSString *lastMessage = dict[@"last_message"];
    if (![lastMessage isKindOfClass:[NSString class]]) {
        lastMessage = @"";
        isUnread = NO;
    }
    [cell setupWithProfileImageUrl:dict[@"small_photo_link"] profileName:dict[@"user_name"] lastMessage:lastMessage dateOfLastMessage:nil showsYouLabel:NO andIsUnread:isUnread];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *selectedUserInfo = [self getDictionaryorIndex:indexPath.row];
    if (selectedUserInfo == nil) {
        return;
    }
    if ([selectedUserInfo[@"user_id"] isEqualToString:[STFacebookController sharedInstance].currentUserId]) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"You cannot chat with yourself." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    if (![[STChatController sharedInstance] canChat]) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Chat connection appears to be offline right now. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
//#ifndef DEBUG
        return;
//#endif
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatScene" bundle:nil];
    STChatRoomViewController *viewController = (STChatRoomViewController *)[storyboard instantiateViewControllerWithIdentifier:@"chat_room"];
    viewController.userInfo = [NSMutableDictionary dictionaryWithDictionary:selectedUserInfo];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UISearchBar delegate method
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [_searchBar setShowsCancelButton:NO animated:YES];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    //_allUsersSearchText = _recentSearchtext = _nearbySearchText = @"";
    [self loadNewDataWithOffset:NO];
    [searchBar resignFirstResponder];
    [_searchBar setShowsCancelButton:NO animated:YES];

}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self searchForText:searchText];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    //hack to enable search button from the beggining
    [_searchBar setShowsCancelButton:YES animated:YES];
    UITextField *searchBarTextField = nil;
    for (UIView *mainview in _searchBar.subviews)
    {
        for (UIView *subview in mainview.subviews) {
            if ([subview isKindOfClass:[UITextField class]])
            {
                searchBarTextField = (UITextField *)subview;
                break;
            }
            
        }
    }
    searchBarTextField.enablesReturnKeyAutomatically = NO;
}

#pragma mark - Helpers
-(void)searchForText:(NSString *)text{
    switch (_segment.selectedSegmentIndex) {
        case STSearchControlAll:
            _allUsersSearchText = text;
            break;
        case STSearchControlNearby:
            _nearbySearchText = text;
            break;
            
        case STSearchControlRecent:
            _recentSearchtext = text;
            break;
    }
    [self loadNewDataWithOffset:NO];
}
- (IBAction)segmentValueChanged:(id)sender {
    switch (_segment.selectedSegmentIndex) {
        case STSearchControlAll:
            _searchBar.text = _allUsersSearchText ;
            break;
        case STSearchControlNearby:
            _searchBar.text = _nearbySearchText ;
            break;
            
        case STSearchControlRecent:
            _searchBar.text = _recentSearchtext ;
            break;
    }
    [self loadNewDataWithOffset:NO];
}

-(void)loadNewDataWithOffset:(BOOL)newOffset{
    __weak STConversationsListViewController *weakSelf = self;
    NSString *searchtext = @"";
    NSInteger offset = 0;
    switch (_segment.selectedSegmentIndex) {
        case STSearchControlAll:{
            searchtext = _allUsersSearchText;
            offset = _allUsersArray.count;
        }
            break;
        case STSearchControlNearby:{
            searchtext = _nearbySearchText;
            offset = _nearbyUsers.count;
        }
            break;
            
        case STSearchControlRecent:{
            searchtext = _recentSearchtext;
            offset = _recentUsers.count;
        }
            break;
    }
    [[STWebServiceController sharedInstance] getUsersForScope:_segment.selectedSegmentIndex  withSearchText:searchtext withOffset:newOffset == YES?offset:0 completion:^(NSDictionary *response) {
        if ([response[@"status_code"] integerValue] == STWebservicesSuccesCod) {
            [weakSelf saveNewDataAndReload:response[@"data"] isNewOffset:newOffset];
        }
        _loadMoreButton.enabled = YES;
        _loadMoreButton = nil;
        
    } andErrorCompletion:^(NSError *error) {
        NSLog(@"Error on getting users");
        _loadMoreButton.enabled = YES;
        _loadMoreButton = nil;
    }];
}

-(void)saveNewDataAndReload:(NSArray *)newData isNewOffset:(BOOL)newOffset{

    switch (_segment.selectedSegmentIndex) {
        case STSearchControlAll:
        {
            if (newOffset == YES) {
                [_allUsersArray addObjectsFromArray:newData];
            }
            else
            {
                [_allUsersArray removeAllObjects];
                [_allUsersArray addObjectsFromArray:newData];
            }
        }
            break;
        case STSearchControlNearby:
        {
            if (newOffset == YES) {
                [_nearbyUsers addObjectsFromArray:newData];
            }
            else
            {
                [_nearbyUsers removeAllObjects];
                [_nearbyUsers addObjectsFromArray:newData];
            }
        }
            break;
            
        case STSearchControlRecent:
        {
            if (newData.count>0) {
                if (newOffset == YES) {
                    [_recentUsers addObjectsFromArray:newData];
                }
                else
                {
                    [_recentUsers removeAllObjects];
                    [_recentUsers addObjectsFromArray:newData];
                }
            }
           
        }
            break;
    }
    
    [_tableView reloadData];
}
#pragma mark - IBACTIONS
- (IBAction)onClickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onLoadMore:(id)sender {
    _loadMoreButton.enabled  = NO;
    [self loadNewDataWithOffset:YES];
    
}

@end

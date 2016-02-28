//
//  STConversationsListViewController.m
//  Status
//
//  Created by Silviu on 01/06/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STConversationsListViewController.h"
#import "STConversationCell.h"
#import "STNetworkQueueManager.h"
#import "STChatRoomViewController.h"
#import "STFacebookLoginController.h"
#import "STChatController.h"
#import "STImageCacheController.h"
#import "UIImageView+Mask.h"
#import "UIImageView+WebCache.h"

#import "STGetUsersRequest.h"

#import "NSString+MD5.h"

@interface STConversationsListViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    NSString *_searchTextString;
    
    NSMutableArray *_allUsersArray;
    NSMutableArray *_nearbyUsers;
    NSMutableArray *_recentUsers;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UIButton *loadMoreButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarHeightContraint;

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
    _searchTextString = @"";
    _allUsersArray = [NSMutableArray new];
    _nearbyUsers = [NSMutableArray new];
    _recentUsers = [NSMutableArray new];
    [_segment setSelectedSegmentIndex:STSearchControlRecent];
    _searchBarHeightContraint.constant = 0;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadNewDataWithOffset:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    _tableView.delegate = nil;
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
    [cell configureCellWithInfo:[self getDictionaryorIndex:indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *selectedUserInfo = [self getDictionaryorIndex:indexPath.row];
    if (selectedUserInfo == nil) {
        return;
    }
    NSString *selectedUserId = [NSString stringFromDictValue:selectedUserInfo[@"user_id"]];
    if ([selectedUserId isEqualToString:[STFacebookLoginController sharedInstance].currentUserId]) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"You cannot chat with yourself." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
//    if (![[STChatController sharedInstance] canChat]) {
//        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Chat connection appears to be offline right now. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
////#ifndef DEBUG
//        return;
////#endif
//    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatScene" bundle:nil];
    STChatRoomViewController *viewController = (STChatRoomViewController *)[storyboard instantiateViewControllerWithIdentifier:@"chat_room"];
    viewController.userInfo = [NSMutableDictionary dictionaryWithDictionary:selectedUserInfo];
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y < 0) {
        if (_searchBarHeightContraint.constant == 0) {
            [self onSwipeDown:nil];
        }
    }
//    NSLog(@"Offset: %@", NSStringFromCGPoint(scrollView.contentOffset));
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
    _searchTextString = text;
    [self loadNewDataWithOffset:NO];
}
- (IBAction)segmentValueChanged:(id)sender {
    _searchBar.text = _searchTextString;
    [self loadNewDataWithOffset:NO];
}

-(void)loadNewDataWithOffset:(BOOL)newOffset{
    __weak STConversationsListViewController *weakSelf = self;
    NSInteger offset = 0;
    switch (_segment.selectedSegmentIndex) {
        case STSearchControlAll:{
            offset = _allUsersArray.count;
        }
            break;
        case STSearchControlNearby:{
            offset = _nearbyUsers.count;
        }
            break;
            
        case STSearchControlRecent:{
            offset = _recentUsers.count;
        }
            break;
    }
    STRequestCompletionBlock completion = ^(id response, NSError *error){
        if ([response[@"status_code"] integerValue] == STWebservicesSuccesCod) {
            [weakSelf saveNewDataAndReload:response[@"data"] isNewOffset:newOffset];
        }
        weakSelf.loadMoreButton.enabled = YES;
        weakSelf.loadMoreButton = nil;
    };

    STRequestFailureBlock failBlock = ^(NSError *error){
        NSLog(@"Error on getting users");
        weakSelf.loadMoreButton.enabled = YES;
        weakSelf.loadMoreButton = nil;
    };

    [STGetUsersRequest getUsersForScope:_segment.selectedSegmentIndex
                         withSearchText:_searchTextString andOffset:newOffset == YES?offset:0
                             completion:completion
                                failure:failBlock];
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
- (IBAction)onSwipeUp:(id)sender {
    _searchBarHeightContraint.constant = 0;
    [UIView animateWithDuration:0.33f animations:^{
        [self.view layoutIfNeeded];
    }];
}
- (IBAction)onSwipeDown:(id)sender {
    _searchBarHeightContraint.constant = 44.f;
    [UIView animateWithDuration:0.33f animations:^{
        [self.view layoutIfNeeded];
    }];
}

@end

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

#import "CreateDataModelHelper.h"
#import "STListUser.h"
#import "STUsersPool.h"
#import "STDataAccessUtils.h"
#import "STConversationUser.h"

@interface STConversationsListViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    NSString *_searchTextString;
    
    NSMutableArray *_allCUsersArray;
    NSMutableArray *_nearbyCUsers;
    NSMutableArray *_recentCUsers;
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
    _allCUsersArray = [NSMutableArray new];
    _nearbyCUsers = [NSMutableArray new];
    _recentCUsers = [NSMutableArray new];
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

-(STConversationUser *)getConversationUserAtIndex:(NSInteger)index{
    NSArray *currentArray = nil;
    switch (_segment.selectedSegmentIndex) {
        case STSearchControlAll:
            currentArray = _allCUsersArray;
            break;
        case STSearchControlNearby:
            currentArray = _nearbyCUsers;
            break;
            
        case STSearchControlRecent:
            currentArray = _recentCUsers;
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
            numRows = _allCUsersArray.count;
            break;
        case STSearchControlNearby:
           numRows = _nearbyCUsers.count;
            break;
            
        case STSearchControlRecent:
            numRows = _recentCUsers.count;
            break;
    }
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STConversationCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([STConversationCell class])];
    [cell configureCellWithConversationUser:[self getConversationUserAtIndex:indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    STConversationUser *selectedCu = [self getConversationUserAtIndex:indexPath.row];
    if (selectedCu == nil) {
        return;
    }
    
    STListUser *lu = [STListUser new];
    lu.uuid = selectedCu.uuid;
    lu.userName = selectedCu.userName;
    lu.thumbnail = selectedCu.thumbnail;

    if ([lu.uuid isEqualToString:[[CoreManager loginService] currentUserUuid]]) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"You cannot chat with yourself." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }

    STChatRoomViewController *viewController = [STChatRoomViewController roomWithUser:lu];
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
            offset = _allCUsersArray.count;
        }
            break;
        case STSearchControlNearby:{
            offset = _nearbyCUsers.count;
        }
            break;
            
        case STSearchControlRecent:{
            offset = _recentCUsers.count;
        }
            break;
    }
    
    [STDataAccessUtils getConversationUsersForScope:_segment.selectedSegmentIndex
                                       searchString:_searchTextString
                                         fromOffset:newOffset == YES?offset:0
                                      andCompletion:^(NSArray *objects, NSError *error) {
                                          weakSelf.loadMoreButton.enabled = YES;
                                          weakSelf.loadMoreButton = nil;
                                          [weakSelf saveNewDataAndReload:objects isNewOffset:newOffset];
                                      }];
}

-(void)saveNewDataAndReload:(NSArray *)newData isNewOffset:(BOOL)newOffset{

    switch (_segment.selectedSegmentIndex) {
        case STSearchControlAll:
        {
            if (newOffset == YES) {
                [_allCUsersArray addObjectsFromArray:newData];
            }
            else
            {
                [_allCUsersArray removeAllObjects];
                [_allCUsersArray addObjectsFromArray:newData];
            }
        }
            break;
        case STSearchControlNearby:
        {
            if (newOffset == YES) {
                [_nearbyCUsers addObjectsFromArray:newData];
            }
            else
            {
                [_nearbyCUsers removeAllObjects];
                [_nearbyCUsers addObjectsFromArray:newData];
            }
        }
            break;
            
        case STSearchControlRecent:
        {
            if (newData.count>0) {
                if (newOffset == YES) {
                    [_recentCUsers addObjectsFromArray:newData];
                }
                else
                {
                    [_recentCUsers removeAllObjects];
                    [_recentCUsers addObjectsFromArray:newData];
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

- (void)containerEndedScrolling {
    _tableView.scrollEnabled = YES;
}

- (void)containerStartedScrolling {
    _tableView.scrollEnabled = NO;
}

@end

//
//  STSuggestionsViewController.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 17/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STSuggestionsViewController.h"
#import "STDataAccessUtils.h"
#import "STSuggestionCell.h"
#import "STDataModelObjects.h"
#import "UIImageView+WebCache.h"

@interface STSuggestionsViewController()<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *_suggestedUsers;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *followAllBtn;

@end

@implementation STSuggestionsViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    _suggestedUsers = [NSMutableArray new];
    [STDataAccessUtils getSuggestUsersWithOffset:@(0) andCompletion:^(NSArray *objects, NSError *error) {
        if (error==nil) {
            [_suggestedUsers addObjectsFromArray:objects];
            [_tableView reloadData];
        }
    }];
}

#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_suggestedUsers && _suggestedUsers.count > 0) {
        NSInteger sum = [self followingNumber];
        _followAllBtn.selected = (sum == _suggestedUsers.count);
    }
    return [_suggestedUsers count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    STSuggestionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"STSuggestionCell"];
    STSuggestedUser *su = _suggestedUsers[indexPath.row];
    [cell.userImageView sd_setImageWithURL:[NSURL URLWithString:su.thumbnail] placeholderImage:[UIImage imageNamed:@"photo placeholder "]];
    cell.followButton.tag = indexPath.row;
    [cell configureCellWithSuggestedUser:su];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [STSuggestionCell cellHeight];
}

#pragma mark - IBACTIONS
- (IBAction)onFollowButtonPressed:(id)sender {
    //update the model then make the request at the end
    NSInteger index = [(UIButton *)sender tag];
    STSuggestedUser *su = [_suggestedUsers objectAtIndex:index];
    BOOL following = [su.followedByCurrentUser boolValue];
    su.followedByCurrentUser = @(!following);
    [self.tableView reloadData];
    
}
- (IBAction)onArrowPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onFollowAllButtonPressed:(id)sender {
    //update the model then make the reuest at the end
    [self actionFollowAll];
    
}

#pragma mark - Model Helpers
-(void)actionFollowAll{
    NSInteger sum = [self followingNumber];
    BOOL shouldFollow = NO;
    if(sum == _suggestedUsers.count)//all users are followed -> unfollow all
        shouldFollow = NO;
    else
        //follow all
        shouldFollow = YES;
    [_suggestedUsers setValue:@(shouldFollow) forKey:@"followedByCurrentUser"];
    [self.tableView reloadData];
}

-(NSInteger)followingNumber{
    NSInteger count = 0;
    for (STSuggestedUser *su in _suggestedUsers) {
        if ([su.followedByCurrentUser boolValue] == YES) {
            count ++;
        }
    }
    return count;
}

@end

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
}
- (IBAction)onArrowPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

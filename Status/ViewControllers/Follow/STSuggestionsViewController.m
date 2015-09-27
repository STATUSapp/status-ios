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
#import "STFollowDataProcessor.h"
#import "STFacebookHelper.h"
#import "STContactsDataProcessor.h"
#import <MessageUI/MessageUI.h>

@interface STSuggestionsViewController()<UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate>
{
    NSMutableArray *_suggestedUsers;
    STFollowDataProcessor *_followProcessor;
    STFacebookHelper *_testHelper;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *followAllBtn;

@end

@implementation STSuggestionsViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    _suggestedUsers = [NSMutableArray new];
    _tableView.hidden = YES;
    [STDataAccessUtils getSuggestUsersWithOffset:@(0) andCompletion:^(NSArray *objects, NSError *error) {
        if (error==nil) {
            [_suggestedUsers addObjectsFromArray:objects];
            _followProcessor = [[STFollowDataProcessor alloc] initWithUsers:objects];
            if (_suggestedUsers.count > 0 ) {
                [_tableView reloadData];
                _tableView.hidden = NO;
            }
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
    //TODO: use this on the facebook invite tab.
//    _testHelper = [STFacebookHelper new];
//    [_testHelper promoteTheApp];
//    return;
    
    //TODO: use this in the emails/sms 
//    STContactsDataProcessor *contactsProcessor = [[STContactsDataProcessor alloc] initWithType:STContactsProcessorTypeEmails];
//    [contactsProcessor switchSelectionForObjectAtIndex:0];
//    [contactsProcessor switchSelectionForObjectAtIndex:1];
//    //make sure the self implements MFMessageComposeViewControllerDelegate protocol
//    [contactsProcessor commitForViewController:self];
//    return;
    if (_suggestedUsers.count == 0) {
        [self dismissViewControllerAnimated:YES completion:nil];

    }
    else{
        [_followProcessor uploadDataToServer:_suggestedUsers withCompletion:^(NSError *error) {
            if (_delegate) {
                [_delegate userDidEndApplyingSugegstions];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
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

#pragma mark - MFMessageComposeViewControllerDelegate

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    NSLog(@"Result: %u", result);
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

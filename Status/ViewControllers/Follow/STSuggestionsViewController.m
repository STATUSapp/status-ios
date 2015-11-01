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
#import "NSIndexPath+Additions.h"
NSInteger const kSuggestedFriendsSection = 0;
NSInteger const kSuggestedPeopleSection = 1;

@interface STSuggestionsViewController()<UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate>
{
    NSMutableArray *_suggestedPeople;
    NSMutableArray *_suggestedFriends;
    
    STFollowDataProcessor *_followPeopleProcessor;
    STFollowDataProcessor *_followFriendsProcessor;
    
    STFacebookHelper *_testHelper;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *followAllBtn;

@end

@implementation STSuggestionsViewController

+(STSuggestionsViewController *)instatiateWithDelegate:(id)delegate
                                         andFollowTyep:(STFollowType)followType{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"SuggestionsScene" bundle:nil];
    STSuggestionsViewController *vc = (STSuggestionsViewController *)[storyBoard instantiateInitialViewController];
    vc.delegate = delegate;
    vc.followType = followType;
    return vc;

}

-(void)loadSuggestedPeople{
    [STDataAccessUtils getSuggestUsersForFollowType:STFollowTypePeople
                                         withOffset:@(0)
                                      andCompletion:^(NSArray *objects, NSError *error) {
                                          if (error==nil) {
                                              [_suggestedPeople addObjectsFromArray:objects];
                                              _followPeopleProcessor = [[STFollowDataProcessor alloc] initWithUsers:objects];
                                              if (_suggestedPeople.count > 0 ) {
                                                  [_tableView reloadData];
                                              }
                                          }
                                      }];
}

-(void)loadSuggestedFriends{
    [STDataAccessUtils getSuggestUsersForFollowType:STFollowTypeFriends
                                         withOffset:@(0)
                                      andCompletion:^(NSArray *objects, NSError *error) {
                                          if (error==nil) {
                                              [_suggestedFriends addObjectsFromArray:objects];
                                              _followFriendsProcessor = [[STFollowDataProcessor alloc] initWithUsers:objects];
                                              if (_suggestedFriends.count > 0 ) {
                                                  [_tableView reloadData];
                                              }
                                          }
                                      }];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    _suggestedPeople = [NSMutableArray new];
    _suggestedFriends = [NSMutableArray new];

    if (_followType == STFollowTypePeople) {
        [self loadSuggestedPeople];
    }
    else if (_followType == STFollowTypeFriends){
        [self loadSuggestedFriends];
    }
    else if (_followType == STFollowTypeFriendsAndPeople){
        [self loadSuggestedPeople];
        [self loadSuggestedFriends];
    }
}

#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger numSections = 1;
    if (_followType == STFollowTypeFriendsAndPeople) {
        numSections = 2;
    }
    return numSections;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numRows = 0;
    switch (_followType) {
        case STFollowTypePeople:
            numRows = [_suggestedPeople count];
            break;
        case STFollowTypeFriends:
            numRows = [_suggestedFriends count];
            break;
        case STFollowTypeFriendsAndPeople:
        {
            if (section == kSuggestedFriendsSection)
                numRows = [_suggestedFriends count];
            else if(section == kSuggestedPeopleSection)
                numRows = [_suggestedPeople count];
        }
            break;

        default:
            break;
    }
    NSArray *suggestions = [self allSuggestions];
    if (suggestions && suggestions.count > 0) {
        NSInteger sum = [self followingNumber];
        _followAllBtn.selected = (sum == suggestions.count);
    }
    return numRows;
}

-(STSuggestedUser *)suggestedUserForIndexpath:(NSIndexPath *)indexPath{
    STSuggestedUser *su = nil;
    switch (_followType) {
        case STFollowTypePeople:
            su = _suggestedPeople[indexPath.row];
            break;
        case STFollowTypeFriends:
            su = _suggestedFriends[indexPath.row];
            break;
        case STFollowTypeFriendsAndPeople:{
            if (indexPath.section == kSuggestedPeopleSection)
                su = _suggestedPeople[indexPath.row];
            else if (indexPath.section == kSuggestedFriendsSection)
                su = _suggestedFriends[indexPath.row];
        }
        default:
            break;
    }
    return su;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    STSuggestionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"STSuggestionCell"];
    STSuggestedUser *su = [self suggestedUserForIndexpath:indexPath];
    [cell.userImageView sd_setImageWithURL:[NSURL URLWithString:su.thumbnail] placeholderImage:[UIImage imageNamed:@"photo placeholder "]];
    cell.followButton.tag = [NSIndexPath tagForIndexPath:indexPath];
    [cell configureCellWithSuggestedUser:su];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [STSuggestionCell cellHeight];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 27.f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view =[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 27.f)];
    view.backgroundColor = [UIColor colorWithRed:71.f/255.f green:72.f/255.f blue:76.f/255.f alpha:1.f];
    
    UILabel *titlelable = [[UILabel alloc] initWithFrame:CGRectMake(20.f,0.f, view.frame.size.width, 27.f)];
    titlelable.textColor = [UIColor colorWithRed:160.f/255.f green:161.f/255.f blue:162.f/255.f alpha:1.f];
    NSString *titleString = @"";
    switch (_followType) {
        case STFollowTypePeople:
            titleString = @"INTERESTING PEOPLE";
            break;
        case STFollowTypeFriends:
            titleString = @"FRIENDS";
            break;
        case STFollowTypeFriendsAndPeople:
        {
            if (section == kSuggestedFriendsSection) {
                titleString = @"FRIENDS";
            }
            else if (section == kSuggestedPeopleSection)
                titleString = @"INTERESTING PEOPLE";
        }
            break;

        default:
            break;
    }
    titlelable.text = titleString;
    [view addSubview:titlelable];
    return view;
}

#pragma mark - IBACTIONS
- (IBAction)onFollowButtonPressed:(id)sender {
    //update the model then make the request at the end
    NSIndexPath *indexPath = [NSIndexPath indexPathWithTag:[(UIButton *)sender tag]];
    STSuggestedUser *su = [self suggestedUserForIndexpath:indexPath];
    BOOL following = [su.followedByCurrentUser boolValue];
    su.followedByCurrentUser = @(!following);
    [self.tableView reloadData];
    
}
- (IBAction)onArrowPressed:(id)sender {
    if ([[self allSuggestions] count] == 0) {
        [self dismissViewControllerAnimated:YES completion:nil];

    }
    else{
        [_followPeopleProcessor uploadDataToServer:_suggestedPeople withCompletion:^(NSError *error) {
            [_followFriendsProcessor uploadDataToServer:_suggestedFriends withCompletion:^(NSError *error) {
                if (_delegate) {
                    [_delegate userDidEndApplyingSugegstions];
                }
                [self dismissViewControllerAnimated:YES completion:nil];

            }];
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
    NSMutableArray *allSuggestions = [NSMutableArray arrayWithArray:[self allSuggestions]];
    if(sum == allSuggestions.count)//all users are followed -> unfollow all
        shouldFollow = NO;
    else
        //follow all
        shouldFollow = YES;
    [allSuggestions setValue:@(shouldFollow) forKey:@"followedByCurrentUser"];
    [self.tableView reloadData];
}

-(NSArray *)allSuggestions{
    NSMutableArray *suggestedArray = [NSMutableArray new];
    switch (_followType) {
        case STFollowTypePeople:
            [suggestedArray addObjectsFromArray:_suggestedPeople];
            break;
        case STFollowTypeFriends:
            [suggestedArray addObjectsFromArray:_suggestedFriends];
            break;
        case STFollowTypeFriendsAndPeople:
            [suggestedArray addObjectsFromArray:_suggestedFriends];
            [suggestedArray addObjectsFromArray:_suggestedPeople];
            break;
        default:
            break;
    }
    return suggestedArray;
}

-(NSInteger)followingNumber{
    NSInteger count = 0;
    NSArray *suggestedArray = [self allSuggestions];
    for (STSuggestedUser *su in suggestedArray) {
        if ([su.followedByCurrentUser boolValue] == YES) {
            count ++;
        }
    }
    return count;
}

@end

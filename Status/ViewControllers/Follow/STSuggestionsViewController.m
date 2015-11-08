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

@property (weak, nonatomic) IBOutlet UILabel *lblInvitePeople;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrBottomTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrHeightInviter;

@property (assign, nonatomic) NSInteger kSuggestedFriendsSection;
@property (assign, nonatomic) NSInteger kSuggestedPeopleSection;

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
    
    [self updateFollowControllsAnimated:NO];
}

#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger numSections = 1;
    if (_followType == STFollowTypeFriendsAndPeople) {
        numSections = 0;
        
        _kSuggestedFriendsSection = -1;
        _kSuggestedPeopleSection = -1;
        
        if (_suggestedFriends.count) {
            numSections ++;
            _kSuggestedFriendsSection ++;
        }
        
        if (_suggestedPeople.count) {
            _kSuggestedPeopleSection = _kSuggestedFriendsSection + 1;
            numSections ++;
        }
        
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
            if (section == _kSuggestedFriendsSection)
                numRows = [_suggestedFriends count];
            else if(section == _kSuggestedPeopleSection)
                numRows = [_suggestedPeople count];
        }
            break;

        default:
            break;
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
            if (indexPath.section == _kSuggestedPeopleSection)
                su = _suggestedPeople[indexPath.row];
            else if (indexPath.section == _kSuggestedFriendsSection)
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
    titlelable.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:10];
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
            if (section == _kSuggestedFriendsSection) {
                titleString = @"FRIENDS";
            }
            else if (section == _kSuggestedPeopleSection)
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    STSuggestionCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    [self onFollowButtonPressed:cell.followButton];
    
    [self updateFollowControllsAnimated:YES];
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

- (void)updateFollowControllsAnimated:(BOOL)animated {
    
    NSInteger selectionsNumber = 0;

    [self.tableView reloadData];
    
    _lblInvitePeople.text = [NSString stringWithFormat:@"%li people selected. Follow them", (long)selectionsNumber];
    
    if (selectionsNumber == 0) {
        _constrBottomTable.constant = 44;
        _constrHeightInviter.constant = 0;
    } else {
        _constrBottomTable.constant = 88;
        _constrHeightInviter.constant = 44;
        
    }
    
    [UIView animateWithDuration: animated? 0.35 : 0 animations:^{
        [self.view layoutIfNeeded];
        _lblInvitePeople.hidden = selectionsNumber == 0 ;
    }];
    
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

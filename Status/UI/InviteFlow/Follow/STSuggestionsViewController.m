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
#import "STLocalNotificationService.h"

static NSString * followAllTitle = @"FOLLOW ALL";
static NSString * followThemTitle = @"FOLLOW THEM";

@interface STSuggestionsViewController()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *followAllBtn;
@property (weak, nonatomic) IBOutlet UILabel *lblInvitePeople;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrBottomTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrHeightInviter;
@property (weak, nonatomic) IBOutlet UIButton *btnFollowAll;

@property (assign, nonatomic) NSInteger kSuggestedFriendsSection;
@property (assign, nonatomic) NSInteger kSuggestedPeopleSection;

@property (strong, nonatomic) NSMutableArray *suggestedPeople;
@property (strong, nonatomic) NSMutableArray *suggestedFriends;

@property (strong, nonatomic) STFollowDataProcessor *followPeopleProcessor;
@property (strong, nonatomic) STFollowDataProcessor *followFriendsProcessor;

@end

@implementation STSuggestionsViewController

+(STSuggestionsViewController *)instatiateWithFollowType:(STFollowType)followType{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"SuggestionsScene" bundle:nil];
    STSuggestionsViewController *vc = (STSuggestionsViewController *)[storyBoard instantiateInitialViewController];
    vc.followType = followType;
    return vc;

}

-(void)loadSuggestedPeople{
    __weak STSuggestionsViewController *weakSelf = self;
    [STDataAccessUtils getSuggestUsersForFollowType:STFollowTypePeople
                                         withOffset:@(0)
                                      andCompletion:^(NSArray *objects, NSError *error) {
                                          __strong STSuggestionsViewController *strongSelf = weakSelf;
                                          if (error==nil) {
                                              [strongSelf.suggestedPeople addObjectsFromArray:objects];
                                              strongSelf.followPeopleProcessor = [[STFollowDataProcessor alloc] initWithUsers:objects];
                                              if (strongSelf.suggestedPeople.count > 0 ) {
                                                  [strongSelf.tableView reloadData];
                                              }
                                          }
                                      }];
}

-(void)loadSuggestedFriends{
    __weak STSuggestionsViewController *weakSelf = self;
    [STDataAccessUtils getSuggestUsersForFollowType:STFollowTypeFriends
                                         withOffset:@(0)
                                      andCompletion:^(NSArray *objects, NSError *error) {
                                          __strong STSuggestionsViewController *strongSelf = weakSelf;
                                          if (error==nil) {
                                              [strongSelf.suggestedFriends addObjectsFromArray:objects];
                                              strongSelf.followFriendsProcessor = [[STFollowDataProcessor alloc] initWithUsers:objects];
                                              if (strongSelf.suggestedFriends.count > 0 ) {
                                                  [strongSelf.tableView reloadData];
                                              }
                                          }
                                      }];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    
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

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
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
    
    if (_suggestedFriends.count + _suggestedPeople.count == 0) {
        _btnFollowAll.enabled = NO;
        [_btnFollowAll setTitle:followAllTitle forState:UIControlStateNormal];
    }else {
        _btnFollowAll.enabled = YES;
    }
    
    [self updateFollowControllsAnimated:YES];
    
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
    [cell.userImageView sd_setImageWithURL:[NSURL URLWithString:su.thumbnail] placeholderImage:[UIImage imageNamed:[su genderImage]]];
    cell.followButton.tag = [NSIndexPath tagForIndexPath:indexPath];
    
    NSInteger numberOfRowsInSection = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    [cell configureCellWithSuggestedUser:su  isLastInSection:(numberOfRowsInSection - 1 == indexPath.row)];
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
        [self closeFlow];
    }
    else{
        __weak STSuggestionsViewController *weakSelf = self;
        [_followPeopleProcessor uploadDataToServer:_suggestedPeople withCompletion:^(NSError *error) {
            __strong STSuggestionsViewController *strongSelf = weakSelf;
            [strongSelf.followFriendsProcessor uploadDataToServer:strongSelf.suggestedFriends withCompletion:^(NSError *error) {
                [strongSelf closeFlow];
                [[CoreManager localNotificationService] postNotificationName:STHomeFlowShouldBeReloadedNotification object:nil userInfo:nil];
            }];
        }];
    }
}


- (void)closeFlow {
    if (self.navigationController.presentingViewController) {
        [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onFollowAllButtonPressed:(id)sender {
    //update the model then make the reuest at the end
    
    if ([_btnFollowAll.titleLabel.text isEqualToString:followAllTitle]) {
        [self actionFollowAll];
    } else {
        [self onArrowPressed:sender];
    }
}

- (void)updateFollowControllsAnimated:(BOOL)animated {
    
    NSInteger selectionsNumber = 0;
    
    NSMutableArray * dataSource = [NSMutableArray array];
    
    switch (self.followType) {
        case STFollowTypeFriends:
            [dataSource addObjectsFromArray:_suggestedFriends];
            break;
        case STFollowTypePeople:
            [dataSource addObjectsFromArray:_suggestedPeople];
            break;
        case STFollowTypeFriendsAndPeople: {
            [dataSource addObjectsFromArray:_suggestedFriends];
            [dataSource addObjectsFromArray:_suggestedPeople];
        }
            break;
            
        default:
            break;
    }
    
    for (STSuggestedUser * user in dataSource) {
        if ([user.followedByCurrentUser boolValue]) {
            selectionsNumber++;
        }
    }
    
    NSString * selectionNumberString = [NSString stringWithFormat:@"%li", (long)selectionsNumber];
    NSString * plainText = selectionsNumber == 1 ? @" person selected." : @" people selected.";
    NSString * boldText = selectionsNumber == 1 ? @" Follow him/her" : @" Follow them";
    
    NSDictionary * lightAttr = @{NSFontAttributeName: [UIFont fontWithName:@"ProximaNova-Light" size:12]};
    NSDictionary * boldAttr = @{NSFontAttributeName: [UIFont fontWithName:@"ProximaNova-Bold" size:12]};
    
    NSRange selRange = NSMakeRange(0, selectionNumberString.length);
    NSRange plainRange = NSMakeRange(selRange.length, plainText.length);
    NSRange boldRange = NSMakeRange(plainRange.length + plainRange.location, boldText.length);
    
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@", selectionNumberString, plainText, boldText]];
    [attrString setAttributes:boldAttr range:selRange];
    [attrString setAttributes:lightAttr range:plainRange];
    [attrString setAttributes:boldAttr range:boldRange];
    
//    _lblInvitePeople.text = [NSString stringWithFormat:@"%li people selected. Follow them", (long)selectionsNumber];
    _lblInvitePeople.attributedText = attrString;
    
    if (selectionsNumber == 0) {
        _constrBottomTable.constant = 44;
        _constrHeightInviter.constant = 0;
    } else {
        _constrBottomTable.constant = 88;
        _constrHeightInviter.constant = 44;
        
    }
    
    if (selectionsNumber == dataSource.count) {
        [_btnFollowAll setTitle:followThemTitle forState:UIControlStateNormal];
    }else {
        [_btnFollowAll setTitle:followAllTitle forState:UIControlStateNormal];
    }
    
    [UIView animateWithDuration: animated? 0.35 : 0 animations:^{
        [self.view layoutIfNeeded];
        self.lblInvitePeople.hidden = selectionsNumber == 0 ;
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

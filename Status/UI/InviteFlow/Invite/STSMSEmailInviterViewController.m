//
//  STSMSEmailInviterViewController.m
//  Status
//
//  Created by Silviu Burlacu on 06/10/15.
//  Copyright © 2015 Andrus Cosmin. All rights reserved.
//


#import <MessageUI/MessageUI.h>
#import "STSMSEmailInviterViewController.h"
#import "STContactsDataProcessor.h"
#import "STAddressBookContact.h"
#import "STInviteFriendCell.h"

static NSString * inviteAllTitle = @"INVITE ALL";
static NSString * inviteThemTitle = @"INVITE THEM";

@interface STSMSEmailInviterViewController ()<UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate, UISearchBarDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) STContactsDataProcessor * dataProcessor;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lblInvitePeople;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrBottomTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrHeightInviter;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *btnInviteAll;

@property (strong, nonatomic) NSMutableArray<STAddressBookContact *> * results;
@property (assign, nonatomic) BOOL isSearching;

@property (assign, nonatomic) NSInteger selectionsNumber;

@property (strong, nonatomic) NSMutableDictionary * sections;


@end

@implementation STSMSEmailInviterViewController

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    _results = [NSMutableArray array];
    for (STAddressBookContact * contact in _dataProcessor.items) {
        if ([contact.fullName.lowercaseString rangeOfString:searchText.lowercaseString].location != NSNotFound) {
            [_results addObject:contact];
        }
    }
    _isSearching = [searchText isEqualToString:@""] ? NO : YES;
    
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    _isSearching = NO;
    [self.view endEditing:YES];
    [self.tableView reloadData];
}

#pragma mark - IBActions


- (IBAction)inviteSelectedPeople:(id)sender {
    [_dataProcessor commitForViewController:self];
    
    if (self.inviteType == STInviteTypeEmail) {
        if ([_delegate respondsToSelector:@selector(userDidInviteSelectionsFromController:)]) {
            [_delegate userDidInviteSelectionsFromController:self];
        }
    }
}


- (IBAction)inviteAll:(id)sender {
    
    if ([_btnInviteAll.titleLabel.text isEqualToString:inviteAllTitle]) {
        for (STAddressBookContact * contact in _dataProcessor.items) {
            contact.selected = @(YES);
        }
        [self.tableView reloadData];
        [self updateInviteButtonTitleAnimated:YES];
    }else {
        [self inviteSelectedPeople:sender];
    }
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (result == MessageComposeResultCancelled) {
        return;
    }
    
    if (result == MessageComposeResultFailed) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Something went wrong" message:@"Please try again later" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self.navigationController presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    
    if ([_delegate respondsToSelector:@selector(userDidInviteSelectionsFromController:)]) {
        [_delegate userDidInviteSelectionsFromController:self];
    }
}


#pragma mark - UITableViewDelegate DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    BOOL found;
    
    self.sections = [NSMutableDictionary dictionary];
    
    NSArray * dataSource = _isSearching ? _results : _dataProcessor.items;
    
    for (STAddressBookContact * contact in dataSource) {
        NSString * firstLetter = [contact.fullName substringToIndex:1];
        found = NO;
        
        for (NSString * str in self.sections.allKeys) {
            if ([str isEqualToString:firstLetter]) {
                found = YES;
            }
        }
        
        if (!found) {
            [self.sections setValue:[NSMutableArray array] forKey:firstLetter];
        }
    }
    
    for (STAddressBookContact * contact in dataSource)
    {
        [[self.sections objectForKey:[contact.fullName substringToIndex:1]] addObject:contact];
    }
    
    // Sort each section array
    for (NSString *key in [self.sections allKeys])
    {
        [[self.sections objectForKey:key] sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:YES]]];
    }
    
    return self.sections.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.sections valueForKey:[[[self.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section]] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 75.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STInviteFriendCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    STAddressBookContact * contact = [[self.sections valueForKey:[[[self.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    
    NSInteger numberOfRowsInSection = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    
    [cell setupWithContact:contact showEmail:(self.inviteType == STInviteTypeEmail) isLastInSection:(numberOfRowsInSection - 1 == indexPath.row)];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    STAddressBookContact * contact =  [[self.sections valueForKey:[[[self.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    if (contact.selected.boolValue == YES) {
        contact.selected = @(NO);
    } else {
        contact.selected = @(YES);
    }
    
    [self updateInviteButtonTitleAnimated:YES];

}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 25.f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view =[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 25.f)];
    view.backgroundColor = [UIColor colorWithRed:71.f/255.f green:72.f/255.f blue:76.f/255.f alpha:1.f];
    
    UILabel *titlelable = [[UILabel alloc] initWithFrame:CGRectMake(20.f,0.f, view.frame.size.width, 25.f)];
    titlelable.textColor = [UIColor colorWithRed:160.f/255.f green:161.f/255.f blue:162.f/255.f alpha:1.f];
    titlelable.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:12];
    NSString *titleString = [[[self.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
    titlelable.text = titleString;
    [view addSubview:titlelable];
    return view;
}

- (void)updateInviteButtonTitleAnimated:(BOOL)animated {
    _selectionsNumber = 0;
    for (STAddressBookContact * contact in _dataProcessor.items) {
        if (contact.selected.boolValue) {
            _selectionsNumber ++;
        }
    }
    [self.tableView reloadData];
    
    NSString * selectionNumberString = [NSString stringWithFormat:@"%li", (long)_selectionsNumber];
    NSString * plainText = _selectionsNumber == 1 ? @" friend selected." : @" friends selected.";
    NSString * boldText = _selectionsNumber == 1 ? @" Invite him/her" : @" Invite them";
    
    NSDictionary * lightAttr = @{NSFontAttributeName: [UIFont fontWithName:@"ProximaNova-Light" size:12]};
    NSDictionary * boldAttr = @{NSFontAttributeName: [UIFont fontWithName:@"ProximaNova-Bold" size:12]};
    
    NSRange selRange = NSMakeRange(0, selectionNumberString.length);
    NSRange plainRange = NSMakeRange(selRange.length, plainText.length);
    NSRange boldRange = NSMakeRange(plainRange.length + plainRange.location, boldText.length);
    
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@", selectionNumberString, plainText, boldText]];
    [attrString setAttributes:boldAttr range:selRange];
    [attrString setAttributes:lightAttr range:plainRange];
    [attrString setAttributes:boldAttr range:boldRange];
    
    _lblInvitePeople.attributedText = attrString;
    
//    _lblInvitePeople.text = [NSString stringWithFormat:@"%li friends selected. Invite them", (long)_selectionsNumber];
    
    if (_selectionsNumber == 0) {
        _constrBottomTable.constant = 44;
        _constrHeightInviter.constant = 0;
    } else {
        _constrBottomTable.constant = 88;
        _constrHeightInviter.constant = 44;
        
    }
    
    if (_selectionsNumber == _dataProcessor.items.count) {
        [_btnInviteAll setTitle:inviteThemTitle forState:UIControlStateNormal];
    }else {
        [_btnInviteAll setTitle:inviteAllTitle forState:UIControlStateNormal];
    }
    
    [UIView animateWithDuration: animated? 0.35 : 0 animations:^{
        [self.view layoutIfNeeded];
        _lblInvitePeople.hidden = _selectionsNumber == 0 ;
    }];

}

- (void)resetSelections {
    
    for (STAddressBookContact * contact in _dataProcessor.items) {
        contact.selected = @(NO);
    }
    [self.tableView reloadData];
    [self updateInviteButtonTitleAnimated:NO];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
    
    if ([_delegate respondsToSelector:@selector(inviterStartedScrolling)]) {
        [_delegate inviterStartedScrolling];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([_delegate respondsToSelector:@selector(inviterEndedScrolling)]) {
        [_delegate inviterEndedScrolling];
    }
}

- (void)parentEndedScrolling {
    _tableView.scrollEnabled = YES;
}

- (void)parentStartedScrolling {
    _tableView.scrollEnabled = NO;
}

#pragma mark - Lifecycle

+ (STSMSEmailInviterViewController *)newControllerWithInviteType:(STInviteType)inviteType delegate:(id<STInvitationsDelegate>)delegate {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Invite" bundle:[NSBundle mainBundle]];
    STSMSEmailInviterViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"STSMSEmailInviterViewController"];
    
    vc.inviteType = inviteType;
    vc.delegate = delegate;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _dataProcessor = [[STContactsDataProcessor alloc] initWithType: self.inviteType == STInviteTypeEmail ? STContactsProcessorTypeEmails : STContactsProcessorTypePhones];
    [self.tableView reloadData];
    
    UIColor * backgroundColor = [UIColor colorWithRed:46.0f/255.0f green:47.0f/255.0f blue:50.0f/255.0f alpha:1];
    self.view.backgroundColor = backgroundColor;
    self.tableView.backgroundColor = backgroundColor;
    
    [self resetSelections];
    
    _searchBar.delegate = self;
    _searchBar.barTintColor = backgroundColor;
    _searchBar.tintColor = backgroundColor;
    _searchBar.backgroundColor = backgroundColor;
    _searchBar.layer.borderColor = backgroundColor.CGColor;
    _searchBar.layer.borderWidth = 3;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

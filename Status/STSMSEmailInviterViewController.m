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


@interface STSMSEmailInviterViewController ()<UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) STContactsDataProcessor * dataProcessor;

@property (weak, nonatomic) IBOutlet UIButton *btnInviteAll;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) NSInteger selectionsNumber;


@end

@implementation STSMSEmailInviterViewController


#pragma mark - IBActions

- (IBAction)invitePeople:(id)sender {
    
    if (_selectionsNumber > 0) {
        [self inviteSelectedPeople];
    }else {
        [self inviteAll];
    }
}

- (void)inviteSelectedPeople {
    [_dataProcessor commitForViewController:self];
    
    if (self.inviteType == STInviteTypeEmail) {
        if ([_delegate respondsToSelector:@selector(userDidInviteSelectionsFromController:)]) {
            [_delegate userDidInviteSelectionsFromController:self];
        }
    }
}


- (void)inviteAll {
    
    for (STAddressBookContact * contact in _dataProcessor.items) {
        contact.selected = @(YES);
    }
    [self.tableView reloadData];
    [self inviteSelectedPeople];
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (result == MessageComposeResultCancelled) {
        return;
    }
    
    if (result == MessageComposeResultFailed) {
        [[[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    
    
    if ([_delegate respondsToSelector:@selector(userDidInviteSelectionsFromController:)]) {
        [_delegate userDidInviteSelectionsFromController:self];
    }
}


#pragma mark - UITableViewDelegate DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataProcessor.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    return self.inviteType == STInviteTypeEmail ? 75.0f : 50.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STInviteFriendCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    STAddressBookContact * contact = _dataProcessor.items[indexPath.row];
    
    [cell setupWithContact:contact showEmail:self.inviteType == STInviteTypeEmail];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    STAddressBookContact * contact = [_dataProcessor.items objectAtIndex:indexPath.row];
    
    if (contact.selected.boolValue == YES) {
        contact.selected = @(NO);
    } else {
        contact.selected = @(YES);
    }
    
    [self updateInviteButtonTitle];

}

- (void)updateInviteButtonTitle {
    _selectionsNumber = 0;
    for (STAddressBookContact * contact in _dataProcessor.items) {
        if (contact.selected.boolValue) {
            _selectionsNumber ++;
        }
    }
    [self.tableView reloadData];
    
    [_btnInviteAll setTitle: _selectionsNumber == 0 ? @"Invite All" : [NSString stringWithFormat:@"Invite friends %li", (long)_selectionsNumber] forState:UIControlStateNormal];
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
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateInviteButtonTitle];
    
    for (STAddressBookContact * contact in _dataProcessor.items) {
        contact.selected = @(NO);
    }
    [self.tableView reloadData];
    [self updateInviteButtonTitle];
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

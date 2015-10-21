//
//  STSMSEmailInviterViewController.m
//  Status
//
//  Created by Silviu Burlacu on 06/10/15.
//  Copyright © 2015 Andrus Cosmin. All rights reserved.
//


#import "STSMSEmailInviterViewController.h"
#import "STContactsDataProcessor.h"
#import "STAddressBookContact.h"

@interface STSMSEmailInviterViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) STContactsDataProcessor * dataProcessor;

@property (weak, nonatomic) IBOutlet UIButton *btnInviteAll;

@end

@implementation STSMSEmailInviterViewController

- (IBAction)inviteAll:(id)sender {
}

#pragma mark - UITableViewDelegate DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataProcessor.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    STAddressBookContact * contact = _dataProcessor.items[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
    
    return cell;
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
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _dataProcessor = [[STContactsDataProcessor alloc] initWithType: self.inviteType == STInviteTypeEmail ? STContactsProcessorTypeEmails : STContactsProcessorTypePhones];
    [self.tableView reloadData];
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

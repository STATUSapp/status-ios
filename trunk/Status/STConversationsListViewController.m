//
//  STConversationsListViewController.m
//  Status
//
//  Created by Silviu on 01/06/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STConversationsListViewController.h"
#import "STConversationCell.h"
#import "STWebServiceController.h"

@interface STConversationsListViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    NSMutableArray *_usersArray;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

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
    __weak STConversationsListViewController *weakSelf = self;
    [[STWebServiceController sharedInstance] getAllUsersWithOffset:0 completion:^(NSDictionary *response) {
        if ([response[@"status_code"] integerValue] == STWebservicesSuccesCod) {
            _usersArray = [NSMutableArray arrayWithArray:response[@"data"]];
            [weakSelf.tableView reloadData];
        }
        
    } andErrorCompletion:^(NSError *error) {
        NSLog(@"Error on getting users");
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableView datasource and delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _usersArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STConversationCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([STConversationCell class])];
    NSDictionary *dict = _usersArray[indexPath.row];
    //TODO: add last message and if it's read. 
    [cell setupWithProfileImageUrl:dict[@"small_photo_link"] profileName:dict[@"user_name"] lastMessage:@"Simona Halep makes Romania proud" dateOfLastMessage:nil showsYouLabel:(indexPath.row % 4 == 0) andIsUnread:(indexPath.row % 2 == 0)];
    
    return cell;
}

#pragma mark - UISearchBar delegate method


@end

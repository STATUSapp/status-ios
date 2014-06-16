//
//  STConversationsListViewController.m
//  Status
//
//  Created by Silviu on 01/06/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STConversationsListViewController.h"
#import "STConversationCell.h"

@interface STConversationsListViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
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
    // Do any additional setup after loading the view.
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
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STConversationCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([STConversationCell class])];
    
    [cell setupWithProfileImageUrl:@"https://www.facebook.com/photo.php?fbid=10152828292371102&set=a.137404931101.134647.26081741101&type=1" profileName:@"Simona Halep" lastMessage:@"Simona Halep makes Romania proud" dateOfLastMessage:nil showsYouLabel:(indexPath.row % 4 == 0) andIsUnread:(indexPath.row % 2 == 0)];
    
    return cell;
}

#pragma mark - UISearchBar delegate method


@end

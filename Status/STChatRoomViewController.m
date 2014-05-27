//
//  STChatRoomViewController.m
//  Status
//
//  Created by Andrus Cosmin on 27/05/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STChatRoomViewController.h"
#import "STMessageReceivedCell.h"
#import "STMessageSendCell.h"

@interface STChatRoomViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation STChatRoomViewController

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

#pragma mark - UITableViewDelegate
-(NSString *)getIdentifierForIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row%2==0) {
        return @"MessageReceivedCell";
    }
    return @"MessageSendCell";
        
}

-(NSString *)getStringForIndexPath:(NSIndexPath *)indexPath{
    NSString *str = @"Message ";
    
    for (int i=0; i<indexPath.row; i++) {
        str = [str stringByAppendingString:@"asafd "];
    }
    
    return str;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *identifier = [self getIdentifierForIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (indexPath.row%2==0) {
        NSString *message = [self getStringForIndexPath:indexPath];
        [(STMessageReceivedCell *)cell configureCellWithMessage:message];
    }
    else
    {
        
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row%2 ==0 ) {
        NSString *message = [self getStringForIndexPath:indexPath];
        return [STMessageReceivedCell cellHeightForText:message];
    }
    
    return 50.f;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 16;
}

@end

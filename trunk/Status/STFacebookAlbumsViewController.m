//
//  FacebookAlbumsViewController.m
//  Status
//
//  Created by Andrus Cosmin on 18/08/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STFacebookAlbumsViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "STFacebookAlbumCell.h"

@interface STFacebookAlbumsViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSArray *_dataSource;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation STFacebookAlbumsViewController

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

    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    if (![[[FBSession activeSession] permissions] containsObject:@"user_photos"]) {
        [[FBSession activeSession] requestNewPublishPermissions:@[@"user_photos"]
                                                defaultAudience:FBSessionDefaultAudienceFriends
                                              completionHandler:^(FBSession *session, NSError *error) {
                                                  [self loadDataSource];
                                              }];
        
    }
    else
        [self loadDataSource];
}

-(void)loadDataSource{
    [FBRequestConnection startWithGraphPath:@"/me/albums"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              _dataSource = [NSArray arrayWithArray:result[@"data"]];
                              
                              NSLog(@"Data source: %@", _dataSource);
                              [_tableView reloadData];
                          }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onClickCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark - UITableViewDelegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    STFacebookAlbumCell *cell = (STFacebookAlbumCell*)[tableView dequeueReusableCellWithIdentifier:@"FBAlbumCell"];
    [cell configureCellWithALbum:_dataSource[indexPath.row]];
    
    return cell;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSString *coverId = _dataSource[indexPath.row][@"cover_photo"];
//    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/{%@}", coverId]
//                                 parameters:nil
//                                 HTTPMethod:@"GET"
//                          completionHandler:^(
//                                              FBRequestConnection *connection,
//                                              id result,
//                                              NSError *error
//                                              ) {
//                              NSLog(@"Photo link: %@", result);
//                          }];
//    NSString *albumId = _dataSource[indexPath.row][@"id"];
//    NSString *graph = [NSString stringWithFormat:@"/{%@}/photos",albumId];
//    [FBRequestConnection startWithGraphPath:graph
//                                 parameters:nil
//                                 HTTPMethod:@"GET"
//                          completionHandler:^(
//                                              FBRequestConnection *connection,
//                                              id result,
//                                              NSError *error
//                                              ) {
//                              /* handle the result */
//                          }];
    
    NSString *albumId = _dataSource[indexPath.row][@"id"];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"thumbnail", @"type",
                            nil
                            ];
    NSString *graph = [NSString stringWithFormat:@"/{%@}/picture",albumId];
    /* make the API call */
    [FBRequestConnection startWithGraphPath:graph
                                 parameters:params
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              /* handle the result */
                          }];
}

@end

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
#import "STAlbumImagesViewController.h"

@interface STFacebookAlbumsViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *_dataSource;
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
                              if (error!=nil) {
                                  NSLog(@"Load error");
                              }
                              else
                              {
                                  _dataSource = [NSMutableArray new];
                                  for (NSDictionary *dict in result[@"data"]) {
                                      if ([dict[@"count"] integerValue] != 0) {
                                          [_dataSource addObject:dict];
                                      }
                                  }
                                  NSLog(@"Data source: %@", _dataSource);
                                  [_tableView reloadData];
                              }
                              
//                              _dataSource = [NSArray arrayWithArray:result[@"data"]];
                              
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    STFacebookAlbumCell *cell = (STFacebookAlbumCell *)sender;
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    STAlbumImagesViewController *destVC = (STAlbumImagesViewController *)[segue destinationViewController];
     NSString *albumId = _dataSource[indexPath.row][@"id"];
    destVC.albumId = albumId;
}


#pragma mark - UITableViewDelegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    STFacebookAlbumCell *cell = (STFacebookAlbumCell*)[tableView dequeueReusableCellWithIdentifier:@"FBAlbumCell"];
    [cell configureCellWithALbum:_dataSource[indexPath.row]];
    
    return cell;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    if ([[[FBSession activeSession] permissions] containsObject:@"user_photos"]) {
//        NSString *albumId = _dataSource[indexPath.row][@"id"];
//        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
//                                @"thumbnail", @"type",
//                                nil
//                                ];
//        NSString *graph = [NSString stringWithFormat:@"/%@/picture",albumId];
//        /* make the API call */
//        [FBRequestConnection startWithGraphPath:graph
//                                     parameters:params
//                                     HTTPMethod:@"GET"
//                              completionHandler:^(
//                                                  FBRequestConnection *connection,
//                                                  id result,
//                                                  NSError *error
//                                                  ) {
//                                  /* handle the result */
//                              }];
//    }
    
   
}

@end

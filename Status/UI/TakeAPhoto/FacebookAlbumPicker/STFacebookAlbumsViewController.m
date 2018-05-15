//
//  FacebookAlbumsViewController.m
//  Status
//
//  Created by Andrus Cosmin on 18/08/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STFacebookAlbumsViewController.h"
#import "STFacebookAlbumCell.h"
#import "STAlbumImagesViewController.h"
#import "STImageCacheController.h"
#import "STFacebookHelper.h"
#import "UIImageView+WebCache.h"
#import "STNavigationService.h"

@interface STFacebookAlbumsViewController ()<UITableViewDataSource, UITableViewDelegate>
{
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

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
    _dataSource = [NSMutableArray new];
    
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self loadDataSource];

}

-(void)dealloc{
    _tableView.delegate = nil;
}

- (void)loadDataSource
{
    __weak STFacebookAlbumsViewController *weakSelf = self;
    [[CoreManager facebookService] loadAlbumsWithRefreshBlock:^(NSArray *newObjects) {
        __strong STFacebookAlbumsViewController *strongSelf = weakSelf;
        if (newObjects.count>0) {
            
            [strongSelf.dataSource addObjectsFromArray:newObjects];
            
            [strongSelf.tableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    STFacebookAlbumCell *cell = (STFacebookAlbumCell*)[tableView dequeueReusableCellWithIdentifier:@"FBAlbumCell"];
    NSDictionary *dict = _dataSource[indexPath.row];
    [cell configureCellWithALbum:dict];
    [cell.albumImageView sd_setImageWithURL:[NSURL URLWithString:dict[@"picture"]]
                           placeholderImage:[UIImage imageNamed:@"placeholder imagine like screen"]];
    return cell;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 73.f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"Sender: %@", sender);
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    STAlbumImagesViewController *destVC = segue.destinationViewController;
    NSDictionary *album = _dataSource[indexPath.row];
    NSString *albumId = album[@"id"];
    destVC.albumId = albumId;
    destVC.albumTitle = album[@"name"];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];


}
@end

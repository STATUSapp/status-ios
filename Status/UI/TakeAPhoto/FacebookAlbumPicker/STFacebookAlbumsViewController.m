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

    _dataSource = [NSMutableArray new];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
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
        if (newObjects.count>0) {
            
            [_dataSource addObjectsFromArray:newObjects];
            
            [weakSelf.tableView reloadData];
            
            //activate this for animation
            /*
             NSUInteger resultsSize = [_dataSource count];

            NSMutableArray *arrayWithIndexPaths = [NSMutableArray array];
            
            for (NSUInteger i = resultsSize; i < resultsSize + newObjects.count; i++)
                [arrayWithIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];

            [weakSelf.tableView insertRowsAtIndexPaths:arrayWithIndexPaths withRowAnimation:UITableViewRowAnimationFade];
             */
        }
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
    STAlbumImagesViewController *destVC = [STAlbumImagesViewController newController];
    NSString *albumId = _dataSource[indexPath.row][@"id"];
    destVC.albumId = albumId;
    [self.parentViewController.navigationController pushViewController:destVC animated:YES];
}
@end

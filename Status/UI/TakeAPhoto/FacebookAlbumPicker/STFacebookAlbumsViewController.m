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

@interface STFacebookAlbumsViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *_dataSource;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) STFacebookHelper *fbLoader;
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
    _fbLoader = [STFacebookHelper new];
    
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
    [_fbLoader loadAlbumsWithRefreshBlock:^(NSArray *newObjects) {
//        if (newObjects.count > 0) {
//            [_dataSource addObjectsFromArray:newObjects];
//            [weakSelf.tableView reloadData];
//        }
        
        if (newObjects.count>0) {
            
            NSUInteger resultsSize = [_dataSource count];
            [_dataSource addObjectsFromArray:newObjects];
            
            NSMutableArray *arrayWithIndexPaths = [NSMutableArray array];
            
            for (NSUInteger i = resultsSize; i < resultsSize + newObjects.count; i++)
                [arrayWithIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];

            [weakSelf.tableView insertRowsAtIndexPaths:arrayWithIndexPaths withRowAnimation:UITableViewRowAnimationFade];
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
    return 44.f;
}

@end

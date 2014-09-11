//
//  STAlbumImagesViewController.m
//  Status
//
//  Created by Andrus Cosmin on 19/08/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STAlbumImagesViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "STAlbumImageCell.h"
#import "STImageCacheController.h"
#import "STSharePhotoViewController.h"
#import "STFacebookAlbumsLoader.h"
#import "UIImage+ImageEffects.h"

@interface STAlbumImagesViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSMutableArray *_dataSource;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) STFacebookAlbumsLoader *fbLoader;
@end

@implementation STAlbumImagesViewController

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
    _dataSource = [NSMutableArray array];
    _fbLoader = [STFacebookAlbumsLoader new];
    __weak STAlbumImagesViewController *weakSelf = self;
    [_fbLoader loadPhotosForAlbum:_albumId
                 withRefreshBlock:^(NSArray *newObjects) {
                     if (newObjects.count>0) {
                         [_dataSource addObjectsFromArray:newObjects];
                         [weakSelf.collectionView reloadData];
                     }
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

#pragma mark UICollectionViewDelegate
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    STAlbumImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"STAlbumImageCell" forIndexPath:indexPath];
    NSString *thumbImageLink = _dataSource[indexPath.row][@"picture"];

#if !USE_SD_WEB
    [[STImageCacheController sharedInstance] loadImageWithName:thumbImageLink andCompletion:^(UIImage *img) {
        cell.albumImageView.image = img;
    } isForFacebook:YES];
    
#else
    [[STImageCacheController sharedInstance] loadImageWithName:thumbImageLink andCompletion:^(UIImage *img) {
        cell.albumImageView.image = img;
    }];
    
#endif
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%@", _dataSource[indexPath.row]);
    NSString *fullImageLink = _dataSource[indexPath.row][@"source"];
    
#if !USE_SD_WEB
    [[STImageCacheController sharedInstance] loadImageWithName:fullImageLink andCompletion:^(UIImage *img) {
        UIImage *newImg = img;//[img imageWithBlurBackground];
        [[NSNotificationCenter defaultCenter] postNotificationName:STFacebookPickerNotification object:newImg];
    } isForFacebook:YES];
    
#else
    [[STImageCacheController sharedInstance] loadImageWithName:fullImageLink andCompletion:^(UIImage *img) {
        UIImage *newImg = img;//[img imageWithBlurBackground];
        [[NSNotificationCenter defaultCenter] postNotificationName:STFacebookPickerNotification object:newImg];
    }];
#endif
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _dataSource.count;
}

@end

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

@interface STAlbumImagesViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSArray *_photosArray;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
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

    //TODO: maybe handle pagging . 
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    [params setValue:@"150" forKey:@"limit"];
        NSString *graph = [NSString stringWithFormat:@"/%@/photos",_albumId];
        [FBRequestConnection startWithGraphPath:graph
                                     parameters:params
                                     HTTPMethod:@"GET"
                              completionHandler:^(
                                                  FBRequestConnection *connection,
                                                  id result,
                                                  NSError *error
                                                  ) {
                                  //TODO: shouls keep 2 versions of small and large photos? picture vs source
                                  _photosArray = [result[@"data"] valueForKey:@"source"];
                                  NSLog(@"Photos array: %@", _photosArray);
                                  [_collectionView reloadData];
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
    
    __weak STAlbumImageCell *weakCell = cell;
    [[STImageCacheController sharedInstance] loadImageWithName:_photosArray[indexPath.row] andCompletion:^(UIImage *img) {
        weakCell.albumImageView.image = img;
    } isForFacebook:YES];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [[STImageCacheController sharedInstance] loadImageWithName:_photosArray[indexPath.row] andCompletion:^(UIImage *img) {
        [[NSNotificationCenter defaultCenter] postNotificationName:STFacebookPickerNotification object:img];
    } isForFacebook:YES];
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _photosArray.count;
}

@end

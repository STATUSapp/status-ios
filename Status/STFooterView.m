//
//  STFooterView.m
//  Status
//
//  Created by Cosmin Andrus on 4/15/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STFooterView.h"
#import "STDataAccessUtils.h"

#import "STSmallFlowCell.h"
#import "STFBAdCell.h"

#import "STFlowTemplate.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>

#import "STNativeAdsController.h"
#import "STMenuController.h"

static const NSInteger kNumberOfTiles = 6;

@interface STFooterView()<UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) NSMutableArray *itemsArray;
@end

@implementation STFooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)showOnlyBackground{
    [self bringSubviewToFront:_bkImageView];
}

-(void)configureFooterWithBkImage:(UIImage *)image
            handlerViewController:(UIViewController *)vc{
    _itemsArray = [NSMutableArray new];
    [[STMenuController sharedInstance] resetCurrentVC:vc];
    [self sendSubviewToBack:_bkImageView];
    _bkImageView.image = image;
    [STDataAccessUtils getFlowTemplatesWithCompletion:^(NSArray *objects, NSError *error) {
        if (error==nil) {
            [_itemsArray addObjectsFromArray:objects];
            _collectionView.delegate = self;
            _collectionView.dataSource = self;
            [_collectionView reloadData];
            [[STNativeAdsController sharedInstance] getAdsInBatchOf:kNumberOfTiles - [_itemsArray count] withCompletion:^(NSArray *response, NSError *error) {
//                for (FBNativeAd *nativeAd in response) {
//                    [nativeAd registerViewForInteraction:_bkImageView withViewController:vc];
//                }
                if (error == nil) {
                    [_itemsArray addObjectsFromArray:response];
                    [_collectionView reloadData];
                }
            }];
        }
    }];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(NSString *)reuseIdentifier{
    return @"footerView";
}

#pragma mark - UICollectionViewDelegate
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    id object = [_itemsArray objectAtIndex:indexPath.row];
    NSString *identifier = @"STSmallFlowCell";
    if ([object isKindOfClass:[FBNativeAd class]]) {
        identifier = @"STFBAdCell";
    }
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if ([cell isKindOfClass:[STSmallFlowCell class]]) {
        [(STSmallFlowCell *)cell configureCellWithFlorTemplate:object];
    }
    else if ([cell isKindOfClass:[STFBAdCell class]]){
        [(STFBAdCell *)cell configureCellWithFBNativeAdd:object];
    }
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [STSmallFlowCell cellSize];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_itemsArray count];
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if (cell!=nil && [cell isKindOfClass:[STSmallFlowCell class]]) {
        STFlowTemplate *ft = [_itemsArray objectAtIndex:indexPath.row];
        if ([ft.type isEqualToString:@"home"]) {
            [[STMenuController sharedInstance] goHome];
        }
        else if ([ft.type isEqualToString:@"popular"]){
            [[STMenuController sharedInstance] goPopular];
        }
        else if ([ft.type isEqualToString:@"recent"]){
            [[STMenuController sharedInstance] goRecent];
        }
        else if ([ft.type isEqualToString:@"nearby"]){
            [[STMenuController sharedInstance] goNearby];
        }
    }
    else
    {
        //TODO: should we handle ads tap?
    }
}

@end

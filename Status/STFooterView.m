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

-(void)configureFooterWithBkImage:(UIImage *)image{
    _itemsArray = [NSMutableArray new];
    [self sendSubviewToBack:_bkImageView];
    _bkImageView.image = image;
    [STDataAccessUtils getFlowTemplatesWithCompletion:^(NSArray *objects, NSError *error) {
        if (error==nil) {
            [_itemsArray addObjectsFromArray:objects];
            _collectionView.delegate = self;
            _collectionView.dataSource = self;
            [_collectionView reloadData];
        }
    }];
    //TODO: get ads and reload data
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

@end

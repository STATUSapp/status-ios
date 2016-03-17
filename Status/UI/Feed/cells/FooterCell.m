//
//  FooterCell.m
//  Status
//
//  Created by Cosmin Home on 06/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "FooterCell.h"
#import "STDataAccessUtils.h"
#import "STFacebookHelper.h"

#import "STSmallFlowCell.h"
#import "STFBAdCell.h"

#import "STFlowTemplate.h"
#import "STNavigationService.h"
#import "STLocalNotificationService.h"

static const NSInteger kNumberOfTiles = 6;

@interface FooterCell ()<UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) NSMutableArray *itemsArray;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UICollectionView *flowsCV;

@end

@implementation FooterCell
-(void)configureFooterWithBkImage:(UIImage *)image{
    _itemsArray = [NSMutableArray new];
    _backgroundImageView.image = [UIImage imageNamed:@"you-saw-all-photos-background-"];
    [STDataAccessUtils getFlowTemplatesWithCompletion:^(NSArray *objects, NSError *error) {
        if (error==nil) {
            [_itemsArray removeAllObjects];
            [_itemsArray addObjectsFromArray:objects];
            _flowsCV.delegate = self;
            _flowsCV.dataSource = self;
            [_flowsCV reloadData];
            [[STFacebookHelper fbNativeAdsService] getAdsInBatchOf:kNumberOfTiles - [_itemsArray count] withCompletion:^(NSArray *response, NSError *error) {
                if (error == nil) {
                    [_itemsArray addObjectsFromArray:response];
                    [_flowsCV reloadData];
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
    return @"FooterCell";
}

#pragma mark - UICollectionViewDelegate
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    id object = [_itemsArray objectAtIndex:indexPath.row];
    NSString *identifier = @"STSmallFlowCell";
    if ([object isKindOfClass:[FBNativeAd class]]) {
        identifier = @"STFBAdCell";
    }
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.layer.masksToBounds = YES;
    cell.layer.borderColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:1.f].CGColor;
    cell.layer.borderWidth = 1.0f;
    cell.layer.contentsScale = [UIScreen mainScreen].scale;
    cell.layer.shadowOpacity = 0.25f;
    cell.layer.shadowRadius = 3.0f;
    cell.layer.shadowOffset = CGSizeZero;
    cell.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.bounds].CGPath;
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale=[[UIScreen mainScreen] scale];
    
    if ([cell isKindOfClass:[STSmallFlowCell class]]) {
        [(STSmallFlowCell *)cell configureCellWithFlorTemplate:object];
    }
    else if ([cell isKindOfClass:[STFBAdCell class]]){
        [(STFBAdCell *)cell configureCellWithFBNativeAdd:object];
        [(FBNativeAd *)object registerViewForInteraction:cell withViewController:[STNavigationService viewControllerForSelectedTab]];
        
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
        [[CoreManager notificationService] postNotificationName:STFooterFlowsNotification object:nil userInfo:@{kFlowTypeKey:ft.type}];
    }
    else
    {
        //not handled in here, handled by the framework
    }
}


@end

//
//  STEarningsViewController.m
//  Status
//
//  Created by Cosmin Andrus on 12/07/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STEarningsViewController.h"
#import "STEarningsCell.h"
#import "STDataAccessUtils.h"
#import "STCommission.h"
#import "STTabBarViewController.h"

@interface STEarningsViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *commissionsArray;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *withdrawButtonHeightConstr;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noWithdrawViewHeightConstr;
@property (weak, nonatomic) IBOutlet UIView *commissionsView;
@property (weak, nonatomic) IBOutlet UIView *noEarningsYetView;

@end

@implementation STEarningsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _commissionsView.hidden = YES;
    _noEarningsYetView.hidden = YES;
    __weak STEarningsViewController *weakSelf = self;
    [STDataAccessUtils getUserCommissionsWithCompletion:^(NSArray *objects, NSError *error) {
        weakSelf.commissionsArray = [NSArray arrayWithArray:objects];
        [weakSelf reloadScreen];
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [(STTabBarViewController *)self.tabBarController setTabBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [(STTabBarViewController *)self.tabBarController setTabBarHidden:NO];
}


-(NSNumber *)calculateTotalUnpaidAmount{
    CGFloat unpaidAmount = 0.f;
    for (STCommission *commissionObj in _commissionsArray) {
        if (commissionObj.commissionState == STCommissionStateNone) {
            unpaidAmount += [commissionObj.commissionAmount doubleValue];
        }
    }
    
    return @(unpaidAmount);
}

-(void)reloadScreen{
    if (_commissionsArray.count == 0) {
        _commissionsView.hidden = YES;
        _noEarningsYetView.hidden = NO;

    }
    else
    {
        _commissionsView.hidden = NO;
        _noEarningsYetView.hidden = YES;
        [_collectionView reloadData];
        NSNumber *unpaidAmount = [self calculateTotalUnpaidAmount];
        if ([unpaidAmount doubleValue] < 100.f) {
            _withdrawButtonHeightConstr.constant = 0.f;
            _noWithdrawViewHeightConstr.constant = 30.f;
        }
        else
        {
            _withdrawButtonHeightConstr.constant = 60.f;
            _noWithdrawViewHeightConstr.constant = 0.f;
        }
        
        NSNumberFormatter *nf = [NSNumberFormatter new];
        nf.maximumFractionDigits = 2;
        _totalLabel.text = [NSString stringWithFormat:@"$ %@", [nf stringFromNumber:unpaidAmount]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1.f;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_commissionsArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    STEarningsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"STEarningsCell" forIndexPath:indexPath];
    STCommission *commissionObj = [_commissionsArray objectAtIndex:indexPath.item];
    [cell configurCellWithCommissionObj:commissionObj];
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake([[UIScreen mainScreen] bounds].size.width, 108.f);
}

#pragma mark - IBActions
- (IBAction)onBackButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onWithDrawPressed:(id)sender {
}


@end

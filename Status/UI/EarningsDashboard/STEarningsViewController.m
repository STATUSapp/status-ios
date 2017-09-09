//
//  STEarningsViewController.m
//  Status
//
//  Created by Cosmin Andrus on 12/07/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STEarningsViewController.h"
#import "STEarningsCell.h"
#import "STEarningsTotalCell.h"
#import "STDataAccessUtils.h"
#import "STCommission.h"
#import "STTabBarViewController.h"
#import "STNavigationService.h"

typedef NS_ENUM(NSUInteger, STEarningsSection) {
    STEarningsSectionCommissions,
    STEarningsSectionTotal,
    STEarningsSectionAvailableAfter,
    STEarningsSectionCount,
};
@interface STEarningsViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray *commissionsArray;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *withdrawButtonHeightConstr;
@property (weak, nonatomic) IBOutlet UIView *commissionsView;
@property (weak, nonatomic) IBOutlet UIView *noEarningsYetView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation STEarningsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _commissionsView.hidden = YES;
    _noEarningsYetView.hidden = YES;
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, 30.f);
    _refreshControl = [[UIRefreshControl alloc] initWithFrame:rect];
    [_refreshControl addTarget:self action:@selector(refreshControlChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.collectionView addSubview:_refreshControl];

    [self getCommissionsFromServer];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [(STTabBarViewController *)self.tabBarController setTabBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [(STTabBarViewController *)self.tabBarController setTabBarHidden:NO];
}

-(void)refreshControlChanged:(UIRefreshControl*)sender{
    NSLog(@"Value changed: %@", @(sender.refreshing));
    [self getCommissionsFromServer];
}


-(void)getCommissionsFromServer{
    __weak STEarningsViewController *weakSelf = self;
    [STDataAccessUtils getUserCommissionsWithCompletion:^(NSArray *objects, NSError *error) {
        weakSelf.commissionsArray = [NSMutableArray arrayWithArray:objects];
        [weakSelf reloadScreen];
    }];
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
    if (_refreshControl.refreshing == YES) {
        [_refreshControl endRefreshing];
    }
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
        }
        else
        {
            _withdrawButtonHeightConstr.constant = 48.f;
        }
        
        [self.view layoutIfNeeded];
        CGPoint bottomOffset = CGPointMake(0, self.collectionView.contentSize.height - self.collectionView.bounds.size.height);
        [self.collectionView setContentOffset:bottomOffset animated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return STEarningsSectionCount;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger numRows = 0;
    if (section == STEarningsSectionCommissions) {
        numRows = [_commissionsArray count];
    }
    else if (section == STEarningsSectionTotal){
        numRows = 1;
    }
    else if (section == STEarningsSectionAvailableAfter){
        NSNumber *unpaidAmount = [self calculateTotalUnpaidAmount];
        numRows = [unpaidAmount doubleValue] >= 100 ? 0 : 1;
    }
    return numRows;
}

-(NSString *)identifierForIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = nil;
    if (indexPath.section == STEarningsSectionCommissions) {
        identifier = @"STEarningsCell";
    }
    else if (indexPath.section == STEarningsSectionTotal){
        identifier = @"STEarningsTotalCell";
    }
    else if (indexPath.section == STEarningsSectionAvailableAfter){
        identifier = @"STEarningsAvailableAfterCell";
    }
    
    NSAssert(identifier, @"Earnings identifier should not be nil");
    
    return identifier;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self identifierForIndexPath:indexPath] forIndexPath:indexPath];
    if ([cell isKindOfClass:[STEarningsCell class]]) {
        STCommission *commissionObj = [_commissionsArray objectAtIndex:indexPath.item];
        [(STEarningsCell *)cell configurCellWithCommissionObj:commissionObj];
    }
    else if([cell isKindOfClass:[STEarningsTotalCell class]]){
        NSNumber *unpaidAmount = [self calculateTotalUnpaidAmount];
        [(STEarningsTotalCell *)cell configureWithTotalAmount:unpaidAmount];
    }
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGSize cellSize = CGSizeZero;
    if (indexPath.section == STEarningsSectionCommissions) {
        cellSize = [STEarningsCell cellSize];
    }
    else if (indexPath.section == STEarningsSectionTotal){
        cellSize = [STEarningsTotalCell cellSize];
    }
    else if (indexPath.section == STEarningsSectionAvailableAfter){
        cellSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 30.f);
    }
    
    return cellSize;
}

#pragma mark - IBActions
- (IBAction)onBackButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onWithDrawPressed:(id)sender {
    __weak STEarningsViewController *weakSelf = self;
    [STDataAccessUtils withdrawCommissionsWithCompletion:^(NSError *error) {
        NSLog(@"Commissions were withrawn : %@", error);
        UIAlertController *alert = nil;
        NSString *alertMessage = nil;
        if (!error) {
            alertMessage = @"Your commissions were withdrawn.";
            [weakSelf getCommissionsFromServer];
        }else{
            alertMessage = @"Your commissions were not withdrawn. Try again later.";
        }
        alert = [UIAlertController alertControllerWithTitle:nil message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [[CoreManager navigationService] presentAlertController:alert];
    }];
}


@end

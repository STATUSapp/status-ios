//
//  STRemoveAdsViewController.m
//  Status
//
//  Created by Silviu on 17/06/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STRemoveAdsViewController.h"
#import "STIAPHelper.h"
#import <StoreKit/StoreKit.h>


@interface STRemoveAdsViewController (){
}
@property (weak, nonatomic) IBOutlet UIButton *removeAdsBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *restorePurchaseBtn;
@property (strong, nonatomic) NSArray * products;
@property (strong, nonatomic) SKProduct * removeAdsProduct;


@end

@implementation STRemoveAdsViewController

+ (STRemoveAdsViewController *)newInstance {
    return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([STRemoveAdsViewController class])];
}

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
    // Do any additional setup after loading the view.
    _removeAdsBtn.enabled = NO;
    _restorePurchaseBtn.enabled = NO;
    [_activityIndicator startAnimating];
    [self loadProductsInfo];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transactionFailed:) name:IAPHelperProductPurchasedFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restorePurchaseFailed:) name:IAPHelperRestorePurchaseFailedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            [self dismissController:nil];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Congratulations" message:@"You have now an ads free STATUS app" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self.navigationController presentViewController:alert animated:YES completion:nil];
        }
    }];
    
}

- (void)transactionFailed:(NSNotification *)notification{
    [_activityIndicator stopAnimating];
    _removeAdsBtn.enabled = YES;
    _restorePurchaseBtn.enabled = YES;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Something went wrong..." message:notification.userInfo[@"error"] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

- (void)restorePurchaseFailed:(NSNotification *)notification{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Something went wrong..." message:notification.userInfo[@"error"] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

- (void)loadProductsInfo {
    _products = nil;
    __weak STRemoveAdsViewController *weakSelf = self;
    [[CoreManager IAPService] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        __strong STRemoveAdsViewController *strongSelf = weakSelf;
        if (success) {
            strongSelf.products = products;
            strongSelf.removeAdsProduct = strongSelf.products.count ? strongSelf.products.firstObject : nil;
            strongSelf.removeAdsBtn.enabled = YES;
            strongSelf.restorePurchaseBtn.enabled = YES;
        }
        
        if (!success || weakSelf.removeAdsProduct == nil) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Something went wrong..." message:@"Tap to dismiss." preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [weakSelf.navigationController presentViewController:alert animated:YES completion:nil];
        }
        
        [weakSelf.activityIndicator stopAnimating];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - IBActions

- (IBAction)onTapRemoveAds:(id)sender {

    [[CoreManager IAPService] buyProduct:_removeAdsProduct];
    _removeAdsBtn.enabled = NO;
    _restorePurchaseBtn.enabled = NO;
    [_activityIndicator startAnimating];
}
- (IBAction)onTapRestoreAds:(id)sender {
    [[CoreManager IAPService] restoreCompletedTransactions];
}

- (IBAction)dismissController:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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


@end

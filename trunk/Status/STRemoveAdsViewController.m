//
//  STRemoveAdsViewController.m
//  Status
//
//  Created by Silviu on 17/06/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STRemoveAdsViewController.h"
#import <StoreKit/StoreKit.h>

static NSString const * removeAdsInAppPurchaseProductID = @"1";

@interface STRemoveAdsViewController ()<SKPaymentTransactionObserver, SKProductsRequestDelegate>
@property (weak, nonatomic) IBOutlet UIButton *removeAdsBtn;

@property (strong, nonatomic) SKProduct * product;

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
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [self getProductInfo];
    _removeAdsBtn.enabled = NO;
}

- (void)getProductInfo {
    if ([SKPaymentQueue canMakePayments]) {
        SKProductsRequest * request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:removeAdsInAppPurchaseProductID]];
        request.delegate = self;
        [request start];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Info" message:@"Please enable In App Purchase in Settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)onTapRemoveAds:(id)sender {
//    [[[UIAlertView alloc] initWithTitle:@"Remove Ads" message:@"In Construction" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    SKPayment * payment = [SKPayment paymentWithProduct:_product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)removeAds {
    [[[UIAlertView alloc] initWithTitle:@"Remove Ads" message:@"In Construction" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

- (IBAction)dismissController:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Payment methods
#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray * products = response.products;
    if (products.count) {
        _product = products.firstObject;
        _removeAdsBtn.enabled = YES;
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Product was not found" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self removeAds];
                [[SKPaymentQueue defaultQueue]
                 finishTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateFailed:
                [[[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Transaction failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                [[SKPaymentQueue defaultQueue]
                 finishTransaction:transaction];
                break;
                
            default:
                break;
        }
    }
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

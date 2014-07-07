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
    NSArray * _products;
    SKProduct * _removeAdsProduct;
}
@property (weak, nonatomic) IBOutlet UIButton *removeAdsBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


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
    [_activityIndicator startAnimating];
    [self loadProductsInfo];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            [self dismissController:nil];
            [[[UIAlertView alloc] initWithTitle:@"Congratulations"
                                        message:@"You have now an ads free STATUS app"
                                       delegate:nil cancelButtonTitle:@"OK"
                              otherButtonTitles: nil]
             show];
        }
    }];
    
}
        

- (void)loadProductsInfo {
    _products = nil;
    
    [[STIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
            _removeAdsProduct = _products.count ? _products.firstObject : nil;
        }
        [_activityIndicator stopAnimating];
        _removeAdsBtn.enabled = YES;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)onTapRemoveAds:(id)sender {

    [[STIAPHelper sharedInstance] buyProduct:_removeAdsProduct];
    _removeAdsBtn.enabled = NO;
    [_activityIndicator startAnimating];
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

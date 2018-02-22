//
//  STTagSuggestions.m
//  Status
//
//  Created by Cosmin Andrus on 06/05/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STTagSuggestions.h"
#import "STTabBarViewController.h"
#import "STTagProductsViewController.h"
#import "STTagProductsManager.h"
#import "STLoadingView.h"

@interface STTagSuggestions ()<STTagProductsProtocol>
{
    STTagProductsViewController *productsVC;
}
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) STLoadingView *customLoadingView;
@property (nonatomic, assign) STTagSuggestionsScreenType screenType;
@property (nonatomic, strong) NSArray <STShopProduct*>* products;
@property (nonatomic, copy) STTagSuggestionsCompletion completion;

@property (nonatomic, strong) STShopProduct *similarSelectedShopProduct;

@end

@implementation STTagSuggestions

+(STTagSuggestions *)suggestionsVCWithScreenType:(STTagSuggestionsScreenType)screenType{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TagProductsScene" bundle:nil];
    STTagSuggestions *vc = [storyboard instantiateViewControllerWithIdentifier:@"TAG_SUGGESTIONS_VC"];
    vc.screenType = screenType;
    return vc;
}

+(STTagSuggestions *)similarProductsScreenWithProducts:(NSArray <STShopProduct *> *)similarProducts andSelectedProduct:(STShopProduct *)selectedProduct withCompletion:(STTagSuggestionsCompletion)completion{
    STTagSuggestions *vc = [STTagSuggestions suggestionsVCWithScreenType:STTagSuggestionsScreenTypeSimilarProducts];
    vc.products = similarProducts;
    vc.similarSelectedShopProduct = selectedProduct;
    vc.completion = completion;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_screenType == STTagSuggestionsScreenTypeSimilarProducts) {
        self.title = NSLocalizedString(@"Similar", nil);
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tagProductsNotification:) name:kTagProductNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [(STTabBarViewController *)self.tabBarController setTabBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [(STTabBarViewController *)self.tabBarController setTabBarHidden:NO];
}

-(void)setScreenLoading:(BOOL)loading{
    if (!_customLoadingView) {
        self.customLoadingView = [STLoadingView loadingViewWithSize:self.view.frame.size];
    }
    if (loading) {
        [self.view addSubview:_customLoadingView];
    }else{
        [_customLoadingView removeFromSuperview];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    productsVC = (STTagProductsViewController *)segue.destinationViewController;
    productsVC.delegate  = self;
    //load search results if needed
    if (_screenType == STTagSuggestionsScreenTypeBarcodeSearch) {
        _products = [STTagProductsManager sharedInstance].searchResult;
    }else if (_screenType == STTagSuggestionsScreenTypeDefault){
        _products = [STTagProductsManager sharedInstance].categoryAndBrandProducts;
    }
    [productsVC updateProducts:_products];
    [self setScreenLoading:(_products.count == 0)];
}

#pragma mark - NSNotification

-(void)tagProductsNotification:(NSNotification *)sender{
    NSDictionary *userInfo = sender.userInfo;
    
    STTagManagerEvent event = [userInfo[kTagProductUserInfoEventKey] integerValue];
    
    switch (event) {
        case STTagManagerEventCategoryAndBrandProducts:
        {
            _products = [STTagProductsManager sharedInstance].categoryAndBrandProducts;
            [productsVC updateProducts:_products];
            [self setScreenLoading:NO];
        }
            break;
        case STTagManagerEventSearchProducts:
        {
            _products = [STTagProductsManager sharedInstance].searchResult;
            [productsVC updateProducts:_products];
            [self setScreenLoading:NO];
        }
        default:
            break;
    }
}

#pragma mark - IBActions

- (IBAction)onBackPressed:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark STTagProductProtocol

-(void)addProductsAction{
    if (_screenType == STTagSuggestionsScreenTypeSimilarProducts) {
        self.completion(_similarSelectedShopProduct);
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        UIViewController *vc = [STTagProductsManager sharedInstance].rootViewController;
        if (vc) {
            [self.navigationController popToViewController:vc animated:YES];
        }
        else
            NSLog(@"The root vc should not be nil in this case");
    }
}

-(void)productsShouldDownloadNextPage{
    if (_screenType == STTagSuggestionsScreenTypeDefault) {
        [[STTagProductsManager sharedInstance] downloadCategoryAndBrandNextPage];
    }
}

-(BOOL)isProductSelected:(STShopProduct *)product{
    if (_screenType == STTagSuggestionsScreenTypeSimilarProducts) {
        return (product == _similarSelectedShopProduct);
    }
    return [[STTagProductsManager sharedInstance] isProductSelected:product];
}

-(void)selectProduct:(STShopProduct *)product{
    if (_screenType == STTagSuggestionsScreenTypeSimilarProducts) {
        _similarSelectedShopProduct = product;
    }else{
        [[STTagProductsManager sharedInstance] processProduct:product];
    }
}

-(NSInteger)selectedProductCount{
    if (_screenType == STTagSuggestionsScreenTypeSimilarProducts) {
        return _similarSelectedShopProduct!=nil ? 1:0;
    }else{
        return [STTagProductsManager sharedInstance].selectedProducts.count;
    }
}

-(NSString *)bottomActionString{
    if (_screenType == STTagSuggestionsScreenTypeSimilarProducts) {
        return NSLocalizedString(@"CHANGE PRODUCT", nil);
    }else{
        NSInteger selectedProductsCount = [self selectedProductCount];
        
        if (selectedProductsCount == 1) {
            return NSLocalizedString(@"ADD PRODUCT", nil);
        }else{
            return NSLocalizedString(@"ADD PRODUCTS", nil);
        }
    }
}
@end

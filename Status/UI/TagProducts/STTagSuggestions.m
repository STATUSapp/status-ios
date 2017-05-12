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

@interface STTagSuggestions ()<STTagProductsProtocol>
{
    STTagProductsViewController *productsVC;
}
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic, strong) NSArray <STShopProduct*>* products;
@end

@implementation STTagSuggestions

+(STTagSuggestions *)suggestionsVC{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TagProductsScene" bundle:nil];
    STTagSuggestions *vc = [storyboard instantiateViewControllerWithIdentifier:@"TAG_SUGGESTIONS_VC"];
    
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    productsVC = (STTagProductsViewController *)segue.destinationViewController;
    productsVC.delegate  = self;
    [productsVC updateProducts:_products];
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
        }
            break;
            
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
    UIViewController *vc = [STTagProductsManager sharedInstance].rootViewController;
    if (vc) {
        [self.navigationController popToViewController:vc animated:YES];
    }
    else
        NSLog(@"The root vc should not be nil in this case");
}
@end

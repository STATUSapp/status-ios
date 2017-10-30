//
//  STTagProductsCategories.m
//  Status
//
//  Created by Cosmin Andrus on 27/03/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STTagProductsContainer.h"
#import "STTagProductsContainerViewController.h"
#import "STTagProductsCategories.h"
#import "STCustomSegment.h"
#import "STCatalogParentCategory.h"
#import "STDataAccessUtils.h"
#import "STTagProductsManager.h"
#import "STTagProductsEmptyWardrobe.h"
#import "STTagProductsViewController.h"
#import "STTagProductsBrands.h"
#import "STTagManualViewController.h"
#import "STTagCustomView.h"
#import "STFacebookLoginController.h"
#import "STBarcodeScannerViewController.h"
#import "STMissingProductViewController.h"
#import "STTabBarViewController.h"

typedef NS_ENUM(NSUInteger, STContainerSelection) {
    STContainerSelectionBarcode,
    STContainerSelectionWizzard,
    STContainerSelectionWardrobe,
    STContainerSelectionManual,
};

typedef NS_ENUM(NSUInteger, STWardrobeSegment) {
    STWardrobeSegmentRecent = 0,
    STWardrobeSegmentCategories,
    STWardrobeSegmentCount,
};

typedef NS_ENUM(NSUInteger, STBarcodeScanState) {
    STBarcodeScanStateDefault = 0,
    STBarcodeScanStateProductNotFound,
    STBarcodeScanStateProductFound,
};


@interface STTagProductsContainer ()<STSCustomSegmentProtocol, STTagProductsEmptyWardrobeProtocol, STTagCategoriesProtocol, STTagProductsProtocol, STTagManualProtocol, STTagCustomViewProtocol, STTagBrandsProtocol, STBarcodeScannerProtocol, STProductNotIndexedProtocol>

@property (weak, nonatomic) IBOutlet STTagCustomView *barcodeView;
@property (weak, nonatomic) IBOutlet STTagCustomView *wizzardView;
@property (weak, nonatomic) IBOutlet STTagCustomView *wardrobeView;
@property (weak, nonatomic) IBOutlet STTagCustomView *manualView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentHeightConstr;

@property (weak, nonatomic) IBOutlet UIView *mainContainer;
@property (nonatomic, assign) STContainerSelection selectionType;
@property (nonatomic, assign) STBarcodeScanState barcodeState;

@property (nonatomic, strong) STCustomSegment *wizardSegment;
@property (nonatomic, strong) STCustomSegment *wardrobeSegment;

@property (weak, nonatomic) IBOutlet UIView *customSegmentHolder;

@property (strong, nonatomic) STTagProductsContainerViewController *containerViewController;

@end

@implementation STTagProductsContainer

+(instancetype)newController{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TagProductsScene"
                                                         bundle:nil];
    STTagProductsContainer *vc = [storyboard instantiateInitialViewController];
    
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    CGRect tabBarFrame = _containerTabBar.tabBar.frame;
//    tabBarFrame.size.height = 0.f;
//    [_containerTabBar.tabBar setFrame:tabBarFrame];
    _barcodeView.delegate = self;
    _wizzardView.delegate = self;
    _wardrobeView.delegate = self;
    _manualView.delegate = self;
    
    _barcodeState = STBarcodeScanStateDefault;
    _selectionType = STContainerSelectionWizzard;
    [self configureTopViewsForSelectedView:_wizzardView];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tagProductsNotification:) name:kTagProductNotification object:nil];
    
    if ([[STTagProductsManager sharedInstance] rootCategoriesDownloaded]) {
        [self addCustomSegmentForType:STContainerSelectionWizzard];
    }
    [self addCustomSegmentForType:STContainerSelectionWardrobe];
    [self configureContainer];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [(STTabBarViewController *)self.tabBarController setTabBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [(STTabBarViewController *)self.tabBarController setTabBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"CONTAINER_VIEW_CONTROLER"]) {
        _containerViewController = segue.destinationViewController;
    }
}

#pragma mark - NSNotification

-(void)tagProductsNotification:(NSNotification *)sender{
    NSDictionary *userInfo = sender.userInfo;
    
    STTagManagerEvent event = [userInfo[kTagProductUserInfoEventKey] integerValue];
    
    switch (event) {
        case STTagManagerEventRootCategoriesDownloaded:
        {
            [self addCustomSegmentForType:STContainerSelectionWizzard];
        }
            break;
        case STTagManagerEventRootCategoriesUpdated:
        {
            [self configureContainer];
        }
            break;
        case STTagManagerEventUsedCategories:
        {
            [self configureContainer];
        }
            break;
        case STTagManagerEventUsedProducts:
        {
            [self configureContainer];
        }
            break;
        case STTagManagerEventSearchProducts:
        {
            if ([[[STTagProductsManager sharedInstance] searchResult] count] > 0) {
                _barcodeState = STBarcodeScanStateProductFound;
                [_containerViewController swapToSegue:kSegueProducts];
                STTagProductsViewController *vc = (STTagProductsViewController *)[_containerViewController currentVC];
                NSArray *products = [[STTagProductsManager sharedInstance] searchResult];
                vc.delegate = self;
                [vc updateProducts:products];

            }else{
                //go to empty search result
                _barcodeState = STBarcodeScanStateProductNotFound;
                _segmentHeightConstr.constant = 0.f;
                [_containerViewController swapToSegue:kSegueMissing];
                STMissingProductViewController *vc = (STMissingProductViewController *)_containerViewController.currentVC;
                vc.delegate = self;                 
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - Helper

-(void)configureContainer{
    if (_selectionType == STContainerSelectionBarcode) {
        if (_barcodeState == STBarcodeScanStateDefault) {
            _segmentHeightConstr.constant = 0.f;
            NSLog(@"_mainContainer.frame = %@", NSStringFromCGRect(_mainContainer.frame));
            [_containerViewController swapToSegue:kSegueBarcode];
            STBarcodeScannerViewController *vc = (STBarcodeScannerViewController *)_containerViewController.currentVC;
            vc.delegate = self;
        }
    }
    else if (_selectionType == STContainerSelectionManual) {
        _segmentHeightConstr.constant = 0.f;
        [_containerViewController swapToSegue:kSegueManual];
        STTagManualViewController *vc = (STTagManualViewController *)_containerViewController.currentVC;
        vc.delegate = self;
        [vc updateProducts:[STTagProductsManager sharedInstance].manualAddedProducts];
    }
    else if (_selectionType == STContainerSelectionWardrobe &&
             _wardrobeSegment.selectedIndex == STWardrobeSegmentRecent){
        NSArray <STShopProduct *> *products = [STTagProductsManager sharedInstance].usedProducts;
        if (products.count == 0) {
            _segmentHeightConstr.constant = 0.f;
            [_containerViewController swapToSegue:kSegueEmpty];
            STTagProductsEmptyWardrobe *vc = (STTagProductsEmptyWardrobe *)[_containerViewController currentVC];
            vc.delegate = self;
        }
        else
        {
            _segmentHeightConstr.constant = 48.f;
            [_containerViewController swapToSegue:kSegueProducts];
            STTagProductsViewController *vc = (STTagProductsViewController *)[_containerViewController currentVC];
            NSArray *products = [[STTagProductsManager sharedInstance] usedProducts];
            vc.delegate = self;
            [vc updateProducts:products];
        }
    }
    else
    {
        
        _segmentHeightConstr.constant = 48.f;
        [_containerViewController swapToSegue:kSegueCategories];
        NSArray <STCatalogCategory *> *categories = nil;
        if (_selectionType == STContainerSelectionWardrobe) {
            categories = [STTagProductsManager sharedInstance].usedCategories;
        }
        else if (_selectionType == STContainerSelectionWizzard){
            NSInteger selectedIndex = _wizardSegment.selectedIndex;
            STCatalogParentCategory *rootCategory = [STTagProductsManager sharedInstance].rootCategories[selectedIndex];
            categories = rootCategory.categories;
            
        }
        STTagProductsCategories *vc = (STTagProductsCategories *)[_containerViewController currentVC];
        vc.delegate = self;
        [vc updateCategories:categories];
    }
}

#pragma mark - Helpers

-(void)addCustomSegmentForType:(STContainerSelection)type{
    STCustomSegment *segment = nil;
    if (type == STContainerSelectionWizzard) {
        _wizardSegment = [STCustomSegment customSegmentWithDelegate:self];
        [_wizardSegment configureSegmentWithDelegate:self];
        segment = _wizardSegment;
    }
    else if (type == STContainerSelectionWardrobe){
        _wardrobeSegment = [STCustomSegment customSegmentWithDelegate:self];
        [_wardrobeSegment configureSegmentWithDelegate:self];
        segment = _wardrobeSegment;
    }
    
    segment.hidden = !(type == _selectionType);

    CGRect rect = segment.frame;
    rect.origin.x = 0.f;
    rect.origin.y = 0.f;
    rect.size.height = _customSegmentHolder.frame.size.height;
    rect.size.width = _customSegmentHolder.frame.size.width;
    
    segment.frame = rect;
    segment.translatesAutoresizingMaskIntoConstraints = YES;
    
    [_customSegmentHolder addSubview:segment];
    
}

-(void)configureTopViewsForSelectedView:(UIView *)selectedView{
    [_barcodeView setViewSelected:(_barcodeView == selectedView)];
    [_wizzardView setViewSelected:(_wizzardView == selectedView)];
    [_wardrobeView setViewSelected:(_wardrobeView == selectedView)];
    [_manualView setViewSelected:(_manualView == selectedView)];
}

#pragma mark - STProductNotIndexedProtocol

-(void)viewDidCancel{
    _barcodeState = STBarcodeScanStateDefault;
    [self configureContainer];
}
-(void)viewDidSendInfoWithBrandName:(NSString *)brandName productName:(NSString *)productName productURK:(NSString *)productURL{
    _barcodeState = STBarcodeScanStateDefault;
    [self configureContainer];
    //TODO: call the proper API then show an alert

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"Thank you for helping us to index more products. Your info were sent." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - STBarcodeScannerProtocol
-(void)barcodeScannerDidScanCode:(NSString *)barcode{
    [[STTagProductsManager sharedInstance] searchProductWithBarcodeString:barcode];
}
#pragma mark - STTagCustomViewProtocol

-(void)customViewWasTapped:(UIView *)customView{

    [self configureTopViewsForSelectedView:customView];
    if (customView == _barcodeView) {
        _selectionType = STContainerSelectionBarcode;
        _wizardSegment.hidden = YES;
        _wardrobeSegment.hidden = YES;
    }
    else if (customView == _wizzardView) {
        _selectionType = STContainerSelectionWizzard;
        _wizardSegment.hidden = NO;
        _wardrobeSegment.hidden = YES;

    }
    else if (customView == _wardrobeView){
        _selectionType = STContainerSelectionWardrobe;
        _wizardSegment.hidden = YES;
        _wardrobeSegment.hidden = NO;

    }
    else if (customView == _manualView){
        _selectionType = STContainerSelectionManual;
        _wizardSegment.hidden = YES;
        _wardrobeSegment.hidden = YES;
    }
    [self configureContainer];
}

#pragma mark - STTagManualProtocol

-(void)manualProductsAdded{
    UIViewController *vc = [STTagProductsManager sharedInstance].rootViewController;
    if (vc) {
        [self.navigationController popToViewController:vc animated:YES];
    }
    else
        NSLog(@"The root vc should not be nil in this case");
}

#pragma mark - STTagCategoriesProtocol

-(void)categoryWasSelected:(STCatalogCategory *)category{
 
    [[STTagProductsManager sharedInstance] updateCategory:category];
    STTagProductsBrands *vc = [STTagProductsBrands brandsViewControllerWithDelegate:self];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)categoriesShouldDownloadNextPage{
    if (_selectionType == STContainerSelectionWardrobe) {
        [[STTagProductsManager sharedInstance] downloadUsedCategoriesNextPage];
    }
    else if (_selectionType == STContainerSelectionWizzard){
        NSInteger selectedIndex = _wizardSegment.selectedIndex;
        STCatalogParentCategory *rootCategory = [STTagProductsManager sharedInstance].rootCategories[selectedIndex];
        [[STTagProductsManager sharedInstance] downloadRootCategoryNextPage:rootCategory];        
    }

}

#pragma mark - STTagBrandsProtocol

-(void)brandsShouldDownloadNextPage{
    [[STTagProductsManager sharedInstance] downloadBrandsNextPage];
}

#pragma mark - STTagProductsProtocol

-(void)addProductsAction{
    if (_selectionType == STContainerSelectionBarcode) {
        _barcodeState = STBarcodeScanStateDefault;
    }
    UIViewController *vc = [STTagProductsManager sharedInstance].rootViewController;
    if (vc) {
        [self.navigationController popToViewController:vc animated:YES];
    }
    else
        NSLog(@"The root vc should not be nil in this case");
}

- (void)productsShouldDownloadNextPage{
    //used products
    [[STTagProductsManager sharedInstance] downloadUsedProductsNextPage];
}


#pragma mark - STTagProductsEmptyWardrobeProtocol

-(void)wizzardOptionSelected{
    _selectionType = STContainerSelectionWizzard;
    [self configureTopViewsForSelectedView:_wizzardView];
}

-(void)manualOptionSelected{
    _selectionType = STContainerSelectionManual;
    [self configureTopViewsForSelectedView:_manualView];
}

#pragma mark - STSCustomSegmentProtocol

- (CGFloat)segmentTopSpace:(STCustomSegment *)segment{
    return 0.f;
}
- (CGFloat)segmentBottomSpace:(STCustomSegment *)segment{
    return 0.f;
}
- (NSInteger)segmentNumberOfButtons:(STCustomSegment *)segment{
    
    if ([segment isEqual:_wizardSegment]) {
        NSArray <STCatalogParentCategory *> *rootCategories = [STTagProductsManager sharedInstance].rootCategories;

        return [rootCategories count];
    }
    else if ([segment isEqual:_wardrobeSegment])
    {
        return STWardrobeSegmentCount;
    }
    
    return 0;
}
- (NSString *)segment:(STCustomSegment *)segment buttonTitleForIndex:(NSInteger)index{
    if ([segment isEqual:_wizardSegment]) {
        NSArray <STCatalogParentCategory *> *rootCategories = [STTagProductsManager sharedInstance].rootCategories;
        STCatalogParentCategory *parentCategory = rootCategories[index];
        return [parentCategory.name uppercaseString];
    }
    else if ([segment isEqual:_wardrobeSegment]){
        if (index == STWardrobeSegmentRecent) {
            return NSLocalizedString(@"RECENT", nil);
        }
        else if (index == STWardrobeSegmentCategories){
            return NSLocalizedString(@"CATEGORIES", nil);
        }
    }
    return @"";
}
- (void)segment:(STCustomSegment *)segment buttonPressedAtIndex:(NSInteger)index{
    NSLog(@"Button pressed index: %@", @(index));
    [self configureContainer];
}

- (NSInteger)segmentDefaultSelectedIndex:(STCustomSegment *)segment{
    if (segment == _wizardSegment) {
        STProfileGender gender = [[CoreManager loginService] currentUserGender];
        switch (gender) {
            case STProfileGenderMale:
                return 1;
                break;
            case STProfileGenderFemale:
                return 0;
                break;
            default:
                return 0;
                break;
        }
        return 0;
    }
    return 0;
}

-(STSegmentSelection)segmentSelectionForSegment:(STCustomSegment *)segment{
    return STSegmentSelectionHighlightButton;
}

-(BOOL)segmentShouldHaveOptionsSeparators:(STCustomSegment *)segment{
    return YES;
}

- (IBAction)onBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

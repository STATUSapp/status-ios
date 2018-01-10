//
//  STTagProductsBrands.m
//  Status
//
//  Created by Cosmin Andrus on 06/05/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STTagProductsBrands.h"
#import "STTagBrandCell.h"
#import "Brand+CoreDataClass.h"
#import "UIImageView+WebCache.h"
#import "STTagProductsManager.h"
#import "STTabBarViewController.h"
#import "STTagSuggestions.h"
#import "STTagBrandSection.h"
#import "STDAOEngine.h"
#import "NSString+Letters.h"
#import "STSectionView.h"
#import "STGetBrandsWithProducts.h"
#import "STCatalogCategory.h"
#import "STLoadingView.h"

@interface STTagProductsBrands ()<UITableViewDelegate, UITableViewDataSource, SLCoreDataRequestManagerDelegate>{
    CGRect keyboardBounds;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarHeightConstr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstr;
@property (strong, nonatomic) STLoadingView *customLoadingView;
@property (nonatomic, strong) STCoreDataRequestManager *currentManager;
@property (nonatomic, strong) NSString *searchText;
@property (nonatomic, assign) BOOL checkNoBrandFound;
@property (nonatomic, strong) NSArray *validBrandIdArray;
@property (nonatomic, strong) NSMutableArray<STTagBrandSection *>*sectionArray;
@property (nonatomic, strong) NSArray *initialBrandsArray;
@property (nonatomic, strong) NSArray *searchDisplayArray;
@property (nonatomic, assign) BOOL validBrandsLoaded;
@end

@implementation STTagProductsBrands

+(STTagProductsBrands *)brandsViewController{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"TagProductsScene" bundle:nil];
    STTagProductsBrands *vc = [storyBoard instantiateViewControllerWithIdentifier:@"TAG_BRANDS_VC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.customLoadingView = [STLoadingView loadingViewWithSize:self.view.frame.size];
    _validBrandsLoaded = NO;
    _searchBarHeightConstr.constant = 0.f;
    [self updateLoadingScreen];
    [self fetchForValidBrands];
    [self updateLoadingScreen];
    [_searchBar setShowsCancelButton:NO animated:NO];
    self.tableView.sectionIndexColor = [UIColor blackColor];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.sectionArray = [@[] mutableCopy];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [(STTabBarViewController *)self.tabBarController setTabBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [(STTabBarViewController *)self.tabBarController setTabBarHidden:NO];
}

-(void)setRequestManager{
    NSSortDescriptor *sd1 = [NSSortDescriptor sortDescriptorWithKey:@"indexString" ascending:YES];
    NSSortDescriptor *sd2 = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    _currentManager = [[STDAOEngine sharedManager] fetchRequestManagerForEntity:@"Brand" sortDescritors:@[sd1, sd2] predicate:nil sectionNameKeyPath:@"indexString" delegate:self andTableView:nil];
}

-(void)updateLoadingScreen{
    if (_validBrandsLoaded) {
        [self.tableView.backgroundView removeFromSuperview];
        self.tableView.backgroundView = nil;
    }
    else
    {
        [self.tableView.backgroundView removeFromSuperview];
        self.tableView.backgroundView = _customLoadingView;
    }
}

-(void)setUpScreenAfterLoading{
    [self onDownSwipe:nil];
    [self updateLoadingScreen];
    [self setRequestManager];
    [self reloadScreenWithCDRM:self.currentManager];
}

-(void)fetchForValidBrands{
    NSString *categoryId = [STTagProductsManager sharedInstance].selectedCategory.uuid;
    __weak STTagProductsBrands *weakSelf = self;
    [STGetBrandsWithProducts getBrandsWithProductsForCategoryId:categoryId withCompletion:^(id response, NSError *error) {
        weakSelf.validBrandsLoaded = YES;
        weakSelf.validBrandIdArray = response;
        [weakSelf setUpScreenAfterLoading];
        
    } failure:^(NSError *error) {
        NSLog(@"Error fetching for valida brands: %@", error);
        weakSelf.validBrandsLoaded = YES;
        [weakSelf setUpScreenAfterLoading];
    }];
}

- (NSArray *)filterForValidBrandsArray:(NSArray *)oldArray{
    if (_validBrandIdArray.count == 0) {
        return oldArray;
    }
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(Brand *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [_validBrandIdArray containsObject:@(evaluatedObject.uuid.integerValue)];
    }];
    NSArray *filteredArray = [oldArray filteredArrayUsingPredicate:predicate];
    return filteredArray;
}

-(void)reloadScreenWithCDRM:(STCoreDataRequestManager *)cdrm{
    self.sectionArray = [@[] mutableCopy];
    self.initialBrandsArray = [cdrm.allObjects sortedArrayUsingComparator:^NSComparisonResult(Brand *obj1, Brand *obj2) {
        return [obj1.name compare:obj2.name];
    }];
    self.initialBrandsArray = [self filterForValidBrandsArray:self.initialBrandsArray];


    self.searchDisplayArray = @[];
    NSMutableArray *indexArray = [NSMutableArray arrayWithArray:[NSString allCapsLetters]];
    [indexArray addObject:@"#"];
    
    NSArray *sectionsIndexNames = [[cdrm sections] valueForKey:@"name"];
    
    for (NSString *indexString in indexArray) {
        NSInteger sectionIndex = [sectionsIndexNames indexOfObject:indexString];
        STTagBrandSection *newSection;
        if (sectionIndex == NSNotFound) {
            newSection = [[STTagBrandSection alloc] initWithSectionName:indexString];
        }else{
            id<NSFetchedResultsSectionInfo> section = [cdrm.sections objectAtIndex:sectionIndex];
            NSArray *validBrands = [self filterForValidBrandsArray:section.objects];
            if (validBrands.count > 0) {
                newSection = [[STTagBrandSection alloc] initWithObjects:validBrands];
            }else{
                newSection = [[STTagBrandSection alloc] initWithSectionName:indexString];
            }
        }
        [self.sectionArray addObject:newSection];

    }
    [self filterOutSections];
    [_tableView reloadData];
}

#pragma mark - Keyboard Notifications

-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    _bottomConstr.constant = -1.f * keyboardBounds.size.height;
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationShowStopped)];
    [UIView setAnimationDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
    
}

-(void) animationShowStopped{
    
//    [UIView animateWithDuration:0.1 animations:^{
//        [_tableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
//
//    }];
    _bottomConstr.constant = -1.f * keyboardBounds.size.height;
    
    
}

-(void) keyboardWillHide:(NSNotification *)note{
    // get a rect for the textView frame
    CGRect containerFrame = self.view.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    _bottomConstr.constant = 0;

    [UIView beginAnimations:nil context:NULL];
    //    [UIView setAnimationDelegate:self];
    //    [UIView setAnimationDidStopSelector:@selector(animationHideStopped)];
    [UIView setAnimationDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
    
}

#pragma mark - IBActions

-(IBAction)onBackPressed:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onNextPressed:(id)sender {
    [[STTagProductsManager sharedInstance] updateBrandId:nil];
    STTagSuggestions *vc = [STTagSuggestions suggestionsVCWithScreenType:STTagSuggestionsScreenTypeDefault];
    
    [self.navigationController pushViewController:vc animated:YES];

}

-(Brand *)brandObjectForIndexPath:(NSIndexPath *)indexPath{
    STTagBrandSection *section = [self.sectionArray objectAtIndex:indexPath.section];
    Brand *brand = [section.sectionItems objectAtIndex:indexPath.row];
    return brand;
}

-(BOOL)updateNoBrandFound{
    if (_searchText.length > 0) {
        return _searchDisplayArray.count == 0;
    }
    return NO;
}

-(BOOL)searchResults{
    return _searchText.length > 0;
}
#pragma mark - UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([self checkNoBrandFound]) {
        return 1;
    }
    if ([self searchResults]) {
        return 1;
    }
    return [self.sectionArray count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([self checkNoBrandFound]) {
        return 1;
    }
    if ([self searchResults]) {
        return _searchDisplayArray.count;
    }

    STTagBrandSection *sectionObj = [self.sectionArray objectAtIndex:section];
    return [sectionObj.sectionItems count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    STTagBrandCell *cell = (STTagBrandCell *)[tableView dequeueReusableCellWithIdentifier:@"STTagBrandCell"];
    if ([self checkNoBrandFound]) {
        [cell setNoBrandFound];
    }else if([self searchResults]){
        BOOL lastItem = (indexPath.row == self.searchDisplayArray.count - 1);
        Brand *brandObj = [self.searchDisplayArray objectAtIndex:indexPath.row];
        cell.nameLabel.text = brandObj.name;
        cell.separatorView.hidden = lastItem;
    }else{
        STTagBrandSection *sectionObj = [self.sectionArray objectAtIndex:indexPath.section];
        BOOL lastItem = (indexPath.row == sectionObj.sectionItems.count - 1);
        Brand *brandObj = [self brandObjectForIndexPath:indexPath];
        cell.nameLabel.text = brandObj.name;
        cell.separatorView.hidden = lastItem;
        
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self checkNoBrandFound])
        return;
    Brand *brand;
    if ([self searchResults]) {
        brand = [self.searchDisplayArray objectAtIndex:indexPath.row];
    }else{
        brand = [self brandObjectForIndexPath:indexPath];
    }
    [[STTagProductsManager sharedInstance] updateBrandId:brand.uuid];
    STTagSuggestions *vc = [STTagSuggestions suggestionsVCWithScreenType:STTagSuggestionsScreenTypeDefault];
    [self.navigationController pushViewController:vc animated:YES];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if ([self checkNoBrandFound])
        return nil;
    if ([self searchResults]) {
        return nil;
    }
    STTagBrandSection *sectionObj = [self.sectionArray objectAtIndex:section];
    if ([sectionObj.sectionItems count] == 0) {
        return nil;
    }
    STSectionView *view = [STSectionView sectionViewWithOwner:self];
    view.sectionLabel.text = sectionObj.sectionName;
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ([self checkNoBrandFound])
        return 0.f;
    if ([self searchResults]) {
        return 0.f;
    }
    STTagBrandSection *sectionObj = [self.sectionArray objectAtIndex:section];
    if ([sectionObj.sectionItems count] == 0) {
        return 0.f;
    }
    return 30.f;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    if ([self searchResults]) {
        return NSNotFound;
    }
    STTagBrandSection *sectionObj = [self.sectionArray objectAtIndex:index];
    if (sectionObj.sectionItems.count == 0) {
        return NSNotFound;
    }
    NSArray *indexArray = [self.sectionArray valueForKey:@"sectionName"];
    return [indexArray indexOfObject:title];
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if ([self searchResults]) {
        return nil;
    }
    NSArray *indexArray = [self.sectionArray valueForKey:@"sectionName"];
    return indexArray;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y < 0) {
        if (_searchBarHeightConstr.constant == 0) {
            [self onDownSwipe:nil];
        }
    }
}

#pragma mark - IBActions

- (IBAction)onDownSwipe:(id)sender {
    _searchBarHeightConstr.constant = 44.f;
    [UIView animateWithDuration:0.33f animations:^{
        [self.view layoutIfNeeded];
    }];

}
- (IBAction)onUpSwipe:(id)sender {
    if (_searchText.length > 0) {
        return;
    }
    _searchBarHeightConstr.constant = 0;
    [UIView animateWithDuration:0.33f animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - UISearchBar delegate method
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [_searchBar setShowsCancelButton:NO animated:YES];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    _searchBar.text = nil;
    _searchText = nil;
    [self filterOutSections];
    [searchBar resignFirstResponder];
    [_searchBar setShowsCancelButton:NO animated:YES];
    [self.tableView reloadData];
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self searchForText:searchBar.text];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    //hack to enable search button from the beggining
    [_searchBar setShowsCancelButton:YES animated:YES];
    UITextField *searchBarTextField = nil;
    for (UIView *mainview in _searchBar.subviews)
    {
        for (UIView *subview in mainview.subviews) {
            if ([subview isKindOfClass:[UITextField class]])
            {
                searchBarTextField = (UITextField *)subview;
                break;
            }
            
        }
    }
    searchBarTextField.enablesReturnKeyAutomatically = NO;
}

#pragma mark - Helpers
-(void)searchForText:(NSString *)text{
    _searchText = text;
    [self filterOutSections];
    [self.tableView reloadData];
}

-(void)filterOutSections{
    if (_searchText.length == 0) {
        _searchDisplayArray = @[];
    }else{
        NSArray *filteredArray = [_initialBrandsArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Brand *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [evaluatedObject.name containsString:_searchText];
        }]];
        
        _searchDisplayArray = [filteredArray sortedArrayUsingComparator:^NSComparisonResult(Brand *obj1, Brand *obj2) {
            NSRange rangeObj1 = [obj1.name rangeOfString:_searchText];
            NSRange rangeObj2 = [obj2.name rangeOfString:_searchText];
            return [@(rangeObj1.location) compare:@(rangeObj2.location)];
        }];
    }
    _checkNoBrandFound = [self updateNoBrandFound];
}

#pragma mark - SLCoreDataRequestManagerDelegate
- (void)controllerContentChanged:(NSArray*)objects forCDReqManager:(STCoreDataRequestManager*)cdReqManager{
    [self reloadScreenWithCDRM:cdReqManager];
}

@end

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

@interface STTagProductsBrands ()<UITableViewDelegate, UITableViewDataSource, SLCoreDataRequestManagerDelegate>{
    CGRect keyboardBounds;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray<STTagBrandSection *>*sectionArray;
@property (nonatomic, strong) NSMutableArray<STTagBrandSection *>*displaySectionArray;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarHeightConstr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstr;
@property (nonatomic, strong) STCoreDataRequestManager *currentManager;
@property (nonatomic, strong) NSString *searchText;
@end

@implementation STTagProductsBrands

+(STTagProductsBrands *)brandsViewController{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"TagProductsScene" bundle:nil];
    STTagProductsBrands *vc = [storyBoard instantiateViewControllerWithIdentifier:@"TAG_BRANDS_VC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.sectionIndexColor = [UIColor blackColor];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.sectionArray = [@[] mutableCopy];
    self.displaySectionArray = [@[] mutableCopy];
    NSSortDescriptor *sd1 = [NSSortDescriptor sortDescriptorWithKey:@"indexString" ascending:YES];
    NSSortDescriptor *sd2 = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    _currentManager = [[STDAOEngine sharedManager] fetchRequestManagerForEntity:@"Brand" sortDescritors:@[sd1, sd2] predicate:nil sectionNameKeyPath:@"indexString" delegate:self andTableView:nil];
    _searchBarHeightConstr.constant = 0;
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

-(void)reloadScreenWithCDRM:(STCoreDataRequestManager *)cdrm{
    self.sectionArray = [@[] mutableCopy];
    self.displaySectionArray = [@[] mutableCopy];
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
            newSection = [[STTagBrandSection alloc] initWithObjects:section.objects];
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
    _bottomConstr.constant = keyboardBounds.size.height;
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
    /*
    [UIView animateWithDuration:0.1 animations:^{
        [_tableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
        
    }];
    _bottomConstr.constant = keyboardBounds.size.height;
     */
    
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
    STTagBrandSection *section = [self.displaySectionArray objectAtIndex:indexPath.section];
    Brand *brand = [section.sectionItems objectAtIndex:indexPath.row];
    return brand;
}

#pragma mark - UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.displaySectionArray count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    STTagBrandSection *sectionObj = [self.displaySectionArray objectAtIndex:section];
    return [sectionObj.sectionItems count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    STTagBrandSection *sectionObj = [self.displaySectionArray objectAtIndex:indexPath.section];
    BOOL lastItem = (indexPath.row == sectionObj.sectionItems.count - 1);
    Brand *brandObj = [self brandObjectForIndexPath:indexPath];
    STTagBrandCell *cell = (STTagBrandCell *)[tableView dequeueReusableCellWithIdentifier:@"STTagBrandCell"];
    cell.nameLabel.text = brandObj.name;
    cell.separatorView.hidden = lastItem;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Brand *brand = [self brandObjectForIndexPath:indexPath];
    [[STTagProductsManager sharedInstance] updateBrandId:brand.uuid];
    STTagSuggestions *vc = [STTagSuggestions suggestionsVCWithScreenType:STTagSuggestionsScreenTypeDefault];
    
    [self.navigationController pushViewController:vc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    STTagBrandSection *sectionObj = [self.displaySectionArray objectAtIndex:section];
    if ([sectionObj.sectionItems count] == 0) {
        return nil;
    }
    STSectionView *view = [STSectionView sectionViewWithOwner:self];
    view.sectionLabel.text = sectionObj.sectionName;
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    STTagBrandSection *sectionObj = [self.displaySectionArray objectAtIndex:section];
    if ([sectionObj.sectionItems count] == 0) {
        return 0.f;
    }
    return 30.f;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    STTagBrandSection *sectionObj = [self.displaySectionArray objectAtIndex:index];
    if (sectionObj.sectionItems.count == 0) {
        return NSNotFound;
    }
    NSArray *indexArray = [self.displaySectionArray valueForKey:@"sectionName"];
    return [indexArray indexOfObject:title];
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    NSArray *indexArray = [self.displaySectionArray valueForKey:@"sectionName"];
    return indexArray;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"scrollView.contentOffset = %@", NSStringFromCGPoint(scrollView.contentOffset));
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
        _displaySectionArray = [NSMutableArray arrayWithArray:_sectionArray];
    }else{
        _displaySectionArray = [@[] mutableCopy];
        for (STTagBrandSection *section in _sectionArray) {
            [_displaySectionArray addObject:[section copyAndFilterObject:_searchText]];
        }
    }
}

#pragma mark - SLCoreDataRequestManagerDelegate
- (void)controllerContentChanged:(NSArray*)objects forCDReqManager:(STCoreDataRequestManager*)cdReqManager{
    [self reloadScreenWithCDRM:cdReqManager];
}

@end

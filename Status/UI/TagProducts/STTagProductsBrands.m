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

@interface STTagProductsBrands ()<UITableViewDelegate, UITableViewDataSource, SLCoreDataRequestManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<STTagBrandSection *>*sectionArray;
@property (nonatomic, strong) STCoreDataRequestManager *currentManager;

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
    NSSortDescriptor *sd1 = [NSSortDescriptor sortDescriptorWithKey:@"indexString" ascending:YES];
    NSSortDescriptor *sd2 = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    _currentManager = [[STDAOEngine sharedManager] fetchRequestManagerForEntity:@"Brand" sortDescritors:@[sd1, sd2] predicate:nil sectionNameKeyPath:@"indexString" delegate:self andTableView:nil];
    NSLog(@"_currentManager = %@", _currentManager);
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
    [_tableView reloadData];
}

#pragma mark - IBActions

-(IBAction)onBackPressed:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(Brand *)brandObjectForIndexPath:(NSIndexPath *)indexPath{
    STTagBrandSection *section = [self.sectionArray objectAtIndex:indexPath.section];
    Brand *brand = [section.sectionItems objectAtIndex:indexPath.row];
    return brand;
}

#pragma mark - UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.sectionArray count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    STTagBrandSection *sectionObj = [self.sectionArray objectAtIndex:section];
    return [sectionObj.sectionItems count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    STTagBrandSection *sectionObj = [self.sectionArray objectAtIndex:indexPath.section];
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

}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    STTagBrandSection *sectionObj = [self.sectionArray objectAtIndex:section];
    if ([sectionObj.sectionItems count] == 0) {
        return nil;
    }
    STSectionView *view = [STSectionView sectionViewWithOwner:self];
    view.sectionLabel.text = sectionObj.sectionName;
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    STTagBrandSection *sectionObj = [self.sectionArray objectAtIndex:section];
    if ([sectionObj.sectionItems count] == 0) {
        return 0.f;
    }
    return 30.f;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    STTagBrandSection *sectionObj = [self.sectionArray objectAtIndex:index];
    if (sectionObj.sectionItems.count == 0) {
        return NSNotFound;
    }
    NSArray *indexArray = [self.sectionArray valueForKey:@"sectionName"];
    return [indexArray indexOfObject:title];
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    NSArray *indexArray = [self.sectionArray valueForKey:@"sectionName"];
    return indexArray;
}

#pragma mark - SLCoreDataRequestManagerDelegate
- (void)controllerContentChanged:(NSArray*)objects forCDReqManager:(STCoreDataRequestManager*)cdReqManager{
    [self reloadScreenWithCDRM:cdReqManager];
}

@end

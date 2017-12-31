//
//  STTagProductsBrands.m
//  Status
//
//  Created by Cosmin Andrus on 06/05/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STTagProductsBrands.h"
#import "STTagBrandCell.h"
#import "STBrandObj.h"
#import "UIImageView+WebCache.h"
#import "STTagProductsManager.h"
#import "STTabBarViewController.h"
#import "STTagSuggestions.h"
#import "STTagBrandSection.h"

@interface STTagProductsBrands ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<STTagBrandSection *>*sectionArray;

@end

@implementation STTagProductsBrands

+(STTagProductsBrands *)brandsViewControllerWithDelegate:(id<STTagBrandsProtocol, STTagSuggestionsProtocol>)delegate{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"TagProductsScene" bundle:nil];
    STTagProductsBrands *vc = [storyBoard instantiateViewControllerWithIdentifier:@"TAG_BRANDS_VC"];
    vc.delegate = delegate;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(brandsWereUpdated:) name:kTagProductNotification object:nil];
    self.sectionArray = [@[] mutableCopy];
    [self reloadScreen];
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

-(void)reloadScreen{
    self.sectionArray = [@[] mutableCopy];
    NSArray *indexArray = [self.sectionArray valueForKey:@"sectionName"];
    for (STBrandObj *brandObj in [STTagProductsManager sharedInstance].brands) {
        NSString *indexStringOfBrand = [brandObj.brandName substringToIndex:1];
        NSInteger indexOfBrand = [indexArray indexOfObject:indexStringOfBrand];
        if (indexOfBrand == NSNotFound) {
            //add new section
            STTagBrandSection *newSection = [[STTagBrandSection alloc] initWithObject:brandObj];
            [self.sectionArray addObject:newSection];
            indexArray = [self.sectionArray valueForKey:@"sectionName"];
        }else{
            //add object into section
            STTagBrandSection *section = [self.sectionArray objectAtIndex:indexOfBrand];
            [section addObjectToItems:brandObj];
        }
    }
    [_tableView reloadData];
}

#pragma mark - UINotifications
- (void)brandsWereUpdated:(NSNotification *)notification{
    STTagManagerEvent event = [notification.userInfo[kTagProductUserInfoEventKey] integerValue];
    if (event == STTagManagerEventBrands) {
        [self reloadScreen];
    }
}

#pragma mark - IBActions

-(IBAction)onBackPressed:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(STBrandObj *)brandObjectForIndexPath:(NSIndexPath *)indexPath{
    STTagBrandSection *section = [self.sectionArray objectAtIndex:indexPath.section];
    STBrandObj *brand = [section.sectionItems objectAtIndex:indexPath.row];
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
    STBrandObj *brandObj = [self brandObjectForIndexPath:indexPath];
    STTagBrandCell *cell = (STTagBrandCell *)[tableView dequeueReusableCellWithIdentifier:@"STTagBrandCell"];
    cell.nameLabel.text = brandObj.brandName;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    STBrandObj *brand = [self brandObjectForIndexPath:indexPath];
    [[STTagProductsManager sharedInstance] updateBrand:brand];
    STTagSuggestions *vc = [STTagSuggestions suggestionsVCWithScreenType:STTagSuggestionsScreenTypeDefault];
    
    [self.navigationController pushViewController:vc animated:YES];

}

-(void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    if (indexPath.section == _sectionArray.count - 1) {//the last section
        if (_delegate && [_delegate respondsToSelector:@selector(brandsShouldDownloadNextPage)]) {
            [_delegate brandsShouldDownloadNextPage];
        }
    }

}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    STTagBrandSection *sectionObj = [self.sectionArray objectAtIndex:section];
    return sectionObj.sectionName;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30.f;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    NSArray *indexArray = [self.sectionArray valueForKey:@"sectionName"];
    return [indexArray indexOfObject:title];
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    NSArray *indexArray = [self.sectionArray valueForKey:@"sectionName"];
    return indexArray;
}
@end

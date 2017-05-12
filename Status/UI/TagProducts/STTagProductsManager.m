//
//  STTagProductsManager.m
//  Status
//
//  Created by Cosmin Andrus on 01/05/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STTagProductsManager.h"
#import "STDataAccessUtils.h"

#import "STCatalogParentCategory.h"
#import "STCatalogCategory.h"
#import "STShopProduct.h"
#import "STBrandObj.h"

NSString *const kTagProductNotification = @"STTagProductNotification";
NSString *const kTagProductUserInfoEventKey = @"notification_event";
NSString *const kTagProductUserInfoIndexKey = @"notification_index";

@interface STTagProductsManager ()

@property (nonatomic, strong, readwrite) NSArray <STCatalogParentCategory *> *rootCategories;
@property (nonatomic, strong, readwrite) NSArray <STCatalogCategory *> *usedCategories;
@property (nonatomic, strong, readwrite) NSArray <STShopProduct *> *usedProducts;
@property (nonatomic, strong, readwrite) NSArray <STBrandObj *> *brands;

@property (nonatomic, strong, readwrite) STCatalogCategory *selectedCategory;
@property (nonatomic, strong, readwrite) STBrandObj *selectedBrand;
@property (nonatomic, strong, readwrite) NSArray <STShopProduct *> *categoryAndBrandProducts;
@property (nonatomic, strong, readwrite) NSMutableArray<STShopProduct *> *selectedProducts;

@end

@implementation STTagProductsManager

+(STTagProductsManager *) sharedInstance{
    static STTagProductsManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

-(void)updateCategory:(STCatalogCategory *)category{
    _selectedCategory = category;
    _selectedBrand = nil;
    _categoryAndBrandProducts = nil;
}

-(void)updateBrand:(STBrandObj *)brand{
    _selectedBrand = brand;
    if (_selectedBrand && _selectedCategory) {
        [self downloadProductsForCategoryAndBrand];
    }
}

-(void)resetManager{
    _selectedBrand = nil;
    _selectedCategory = nil;
    _categoryAndBrandProducts = nil;
    _rootViewController = nil;
    _selectedProducts = nil;
}

-(void)processProduct:(STShopProduct *)product{
    if (!_selectedProducts) {
        _selectedProducts = [NSMutableArray new];
    }
    
    if ([self isProductSelected:product]) {
        [_selectedProducts removeObject:product];
    }
    else
    {
        [_selectedProducts addObject:product];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTagProductNotification object:nil userInfo:@{kTagProductUserInfoEventKey:@(STTagManagerEventSelectedProducts)}];
}

-(BOOL)isProductSelected:(STShopProduct *)product{
    return [_selectedProducts containsObject:product];
}

-(BOOL)rootCategoriesDownloaded{
    return [_rootCategories count] > 0;
}

-(NSArray <STShopProduct *> *)manualAddedProducts{
    return [_selectedProducts filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(STShopProduct *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return (evaluatedObject.uuid == nil);
    }]];
}

-(void)startDownload{
    [self downloadRootCatgories];
    [self downloadUsedCategories];
    [self downloadUsedProducts];
    [self downloadBrands];
}

-(void)downloadRootCatgories{
    __weak STTagProductsManager *weakSelf = self;
    [STDataAccessUtils getCatalogParentEntitiesWithCompletion:^(NSArray *objects, NSError *error) {
        if (!error) {
            weakSelf.rootCategories = [NSArray arrayWithArray:objects];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTagProductNotification object:nil userInfo:@{kTagProductUserInfoEventKey:@(STTagManagerEventRootCategoriesDownloaded)}];
            for (STCatalogParentCategory *rootCat in weakSelf.rootCategories) {
                [weakSelf downloadCategoriesForRootCategory:rootCat];
            }
        }
    }];
}

-(void)downloadCategoriesForRootCategory:(STCatalogParentCategory *)rootCategory{
    __weak STTagProductsManager *weakSelf = self;
    [STDataAccessUtils getCatalogCategoriesForParentCategoryId:rootCategory.uuid withCompletion:^(NSArray *objects, NSError *error) {
        rootCategory.categories = [NSArray arrayWithArray:objects];
        NSInteger index = [weakSelf.rootCategories indexOfObject:rootCategory];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTagProductNotification object:nil userInfo:@{kTagProductUserInfoEventKey:@(STTagManagerEventRootCategoriesUpdated), kTagProductUserInfoIndexKey:@(index)}];
    }];
}

-(void)downloadUsedCategories{
    __weak STTagProductsManager *weakSelf = self;
    [STDataAccessUtils getUsedCatalogCategoriesWithCompletion:^(NSArray *objects, NSError *error) {
        weakSelf.usedCategories = [NSArray arrayWithArray:objects];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kTagProductNotification object:nil userInfo:@{kTagProductUserInfoEventKey:@(STTagManagerEventUsedCategories)}];
    }];
}

-(void)downloadUsedProducts{
    __weak STTagProductsManager *weakSelf = self;
    [STDataAccessUtils getUsedSuggestionsForCategory:nil
                                       andCompletion:^(NSArray *objects, NSError *error) {
                                           NSLog(@"Received objects: %@", objects);
                                           weakSelf.usedProducts = [NSArray arrayWithArray:objects];
                                           [[NSNotificationCenter defaultCenter] postNotificationName:kTagProductNotification object:nil userInfo:@{kTagProductUserInfoEventKey:@(STTagManagerEventUsedProducts)}];
                                       }];

}

-(void)downloadBrands{
    __weak STTagProductsManager *weakSelf = self;
    [STDataAccessUtils getBrandsEntitiesWithCompletion:^(NSArray *objects, NSError *error) {
        weakSelf.brands = [NSArray arrayWithArray:objects];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTagProductNotification object:nil userInfo:@{kTagProductUserInfoEventKey:@(STTagManagerEventUsedProducts)}];
    }];
}

-(void)downloadProductsForCategoryAndBrand{
    __weak STTagProductsManager *weakSelf = self;

    [STDataAccessUtils getSuggestionsForCategory:_selectedCategory.uuid
                                        andBrand:_selectedBrand.uuid
                                   andCompletion:^(NSArray *objects, NSError *error) {
                                       weakSelf.categoryAndBrandProducts = [NSArray arrayWithArray:objects];
                                       [[NSNotificationCenter defaultCenter] postNotificationName:kTagProductNotification object:nil userInfo:@{kTagProductUserInfoEventKey:@(STTagManagerEventCategoryAndBrandProducts)}];
                                   }];
}

@end

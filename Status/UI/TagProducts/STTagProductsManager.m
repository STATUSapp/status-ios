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

NSInteger const kCatalogFirstPage = 1;
NSInteger const kCatalogNoMorePagesIndex = -1;

@interface STTagProductsManager ()

@property (nonatomic, strong, readwrite) NSArray <STCatalogParentCategory *> *rootCategories;
@property (nonatomic, strong, readwrite) NSArray <STCatalogCategory *> *usedCategories;
@property (nonatomic, strong, readwrite) NSArray <STShopProduct *> *usedProducts;
@property (nonatomic, strong, readwrite) NSArray <STBrandObj *> *brands;

@property (nonatomic, strong, readwrite) STCatalogCategory *selectedCategory;
@property (nonatomic, strong, readwrite) STBrandObj *selectedBrand;
@property (nonatomic, strong, readwrite) NSArray <STShopProduct *> *categoryAndBrandProducts;
@property (nonatomic, strong, readwrite) NSMutableArray<STShopProduct *> *selectedProducts;

@property (nonatomic, assign) NSInteger brandsPageIndex;
@property (nonatomic, assign) NSInteger usedCategoriesPageIndex;
@property (nonatomic, assign) NSInteger usedProductsPageIndex;
@property (nonatomic, assign) NSInteger categoryAndBrondPageIndex;
@property (nonatomic, strong) NSMutableDictionary *rootCategoryPageIndexes;

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
    _categoryAndBrondPageIndex = kCatalogFirstPage;
}

-(void)updateBrand:(STBrandObj *)brand{
    _selectedBrand = brand;
    _categoryAndBrondPageIndex = kCatalogFirstPage;
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
    _brandsPageIndex = kCatalogFirstPage;
    _usedCategoriesPageIndex = kCatalogFirstPage;
    _usedProductsPageIndex = kCatalogFirstPage;
    _categoryAndBrondPageIndex = kCatalogFirstPage;
    _rootCategoryPageIndexes = nil;
}

-(NSInteger)currentPageIndexForRootCategory:(STCatalogParentCategory *)rootCategory{
    if (!_rootCategoryPageIndexes) {
        _rootCategoryPageIndexes = [NSMutableDictionary new];
        return kCatalogFirstPage;
    }
    
    NSString *key = rootCategory.uuid;
    if (!key || [key isKindOfClass:[NSNull class]]) {
        NSAssert(YES, @"root category key should not be nil");
        return kCatalogFirstPage;
    }
    
    NSNumber *indexNumber = [_rootCategoryPageIndexes valueForKey:key];
    if (!indexNumber) {
        return kCatalogFirstPage;
    }
    
    return [indexNumber integerValue];
}

-(void)setPageIndex:(NSInteger)pageIndex
    forRootCategory:(STCatalogParentCategory *)rootCategory{
    
    if (!_rootCategoryPageIndexes) {
        _rootCategoryPageIndexes = [NSMutableDictionary new];
    }
    
    NSString *key = rootCategory.uuid;
    if (!key || [key isKindOfClass:[NSNull class]]) {
        NSAssert(YES, @"root category key should not be nil");
    }

    [_rootCategoryPageIndexes setValue:@(pageIndex)
                                forKey:key];
}

-(void)processProduct:(STShopProduct *)product{
    if (!_selectedProducts) {
        _selectedProducts = [NSMutableArray new];
    }
    if (product.uuid) {
        if ([self isProductSelected:product]) {
            [_selectedProducts removeObject:product];
        }
        else
        {
            [_selectedProducts addObject:product];
        }
    }
    else
    {
        if (![self isProductSelected:product]) {
            [_selectedProducts addObject:product];

        }
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
        return (evaluatedObject.uuid == nil && evaluatedObject.mainImageUrl == nil);
    }]];
}

-(void)startDownload{
    _brandsPageIndex = kCatalogFirstPage;
    _usedCategoriesPageIndex = kCatalogFirstPage;
    _usedProductsPageIndex = kCatalogFirstPage;
    _categoryAndBrondPageIndex = kCatalogFirstPage;
    _rootCategoryPageIndexes = nil;
    [self downloadRootCatgories];
    [self downloadUsedCategories];
    [self downloadUsedProducts];
    [self downloadBrands];
}

-(void)downloadBrandsNextPage{
    [self downloadBrands];
}

-(void)downloadUsedCategoriesNextPage{
    [self downloadUsedCategories];
}

-(void)downloadUsedProductsNextPage{
    [self downloadUsedProducts];
}

-(void)downloadCategoryAndBrandNextPage{
    [self downloadProductsForCategoryAndBrand];
}

-(void)downloadRootCategoryNextPage:(STCatalogParentCategory *)rootCatgory{
    [self downloadCategoriesForRootCategory:rootCatgory];
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
    __block NSInteger pageIndex = [self currentPageIndexForRootCategory:rootCategory];
    if (pageIndex == kCatalogNoMorePagesIndex) {
        NSLog(@"No more categories to be downloaded for root category: %@", rootCategory.uuid);
        return;
    }
    [STDataAccessUtils getCatalogCategoriesForParentCategoryId:rootCategory.uuid
                                                  andPageIndex:pageIndex withCompletion:^(NSArray *objects, NSError *error) {
                                                      if (!error) {
                                                          [rootCategory addCategoryObjects:[NSArray arrayWithArray:objects]];
                                                          if ([objects count] < kCatalogDownloadPageSize) {
                                                              [self setPageIndex:-1
                                                                 forRootCategory:rootCategory];
                                                              NSLog(@"Categories download for root category: %@ STOP", rootCategory.uuid);
                                                          }
                                                          else{
                                                              [self setPageIndex:pageIndex+1
                                                                 forRootCategory:rootCategory];

                                                          }
                                                          NSInteger index = [weakSelf.rootCategories indexOfObject:rootCategory];
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:kTagProductNotification object:nil userInfo:@{kTagProductUserInfoEventKey:@(STTagManagerEventRootCategoriesUpdated), kTagProductUserInfoIndexKey:@(index)}];
                                                      }
                                                  }];
}

-(void)downloadUsedCategories{
    if (_usedCategoriesPageIndex == kCatalogNoMorePagesIndex) {
        NSLog(@"No more used categories to be downloaded");
        return;
    }
    __weak STTagProductsManager *weakSelf = self;
    [STDataAccessUtils getUsedCatalogCategoriesAtPageIndex:_usedCategoriesPageIndex
                                            withCompletion:^(NSArray *objects, NSError *error) {
                                                if (!error) {
                                                    NSMutableArray *categories = [NSMutableArray new];
                                                    if (weakSelf.usedCategories) {
                                                        [categories addObjectsFromArray:weakSelf.usedCategories];
                                                    }
                                                    [categories addObjectsFromArray:objects];
                                                    
                                                    weakSelf.usedCategories = [NSArray arrayWithArray:categories];
                                                    if ([objects count] < kCatalogDownloadPageSize) {
                                                        weakSelf.usedCategoriesPageIndex = kCatalogNoMorePagesIndex;
                                                        NSLog(@"Used categories download STOP");
                                                    }else{
                                                        weakSelf.usedCategoriesPageIndex ++;
                                                    }
                                                    [[NSNotificationCenter defaultCenter] postNotificationName:kTagProductNotification object:nil userInfo:@{kTagProductUserInfoEventKey:@(STTagManagerEventUsedCategories)}];
                                                }
    }];
}

-(void)downloadUsedProducts{
    if (_usedProductsPageIndex == kCatalogNoMorePagesIndex) {
        NSLog(@"No more used products to be downloaded");
        return;
    }
    __weak STTagProductsManager *weakSelf = self;
    [STDataAccessUtils getUsedSuggestionsForCategory:nil
                                        andPageIndex:_usedProductsPageIndex
                                       andCompletion:^(NSArray *objects, NSError *error) {
                                           if (!error) {
                                               NSLog(@"Received objects: %@", objects);
                                               NSMutableArray *usedProducts = [NSMutableArray new];
                                               if (weakSelf.usedProducts) {
                                                   [usedProducts addObjectsFromArray:weakSelf.usedProducts];
                                               }
                                               [usedProducts addObjectsFromArray:objects];
                                               weakSelf.usedProducts = [NSArray arrayWithArray:usedProducts];
                                               if ([objects count] < kCatalogDownloadPageSize) {
                                                   weakSelf.usedProductsPageIndex = kCatalogNoMorePagesIndex;
                                                   NSLog(@"Used products download STOP");
                                               }else{
                                                   weakSelf.usedProductsPageIndex ++;
                                               }
                                               [[NSNotificationCenter defaultCenter] postNotificationName:kTagProductNotification object:nil userInfo:@{kTagProductUserInfoEventKey:@(STTagManagerEventUsedProducts)}];
                                           }
                                       }];

}

-(void)downloadBrands{
    if (_brandsPageIndex == kCatalogNoMorePagesIndex) {
        NSLog(@"No more brands to be downloaded!");
        return;
    }
    __weak STTagProductsManager *weakSelf = self;
    STDataAccessCompletionBlock completion = ^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *brands = [NSMutableArray new];
            if (weakSelf.brands) {
                [brands addObjectsFromArray:weakSelf.brands];
            }
            [brands addObjectsFromArray:objects];
            weakSelf.brands = [NSArray arrayWithArray:brands];
            if ([objects count] < kCatalogDownloadPageSize) {
                NSLog(@"Brands download STOP");
                weakSelf.brandsPageIndex = kCatalogNoMorePagesIndex;
            }else{
                weakSelf.brandsPageIndex ++;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kTagProductNotification object:nil userInfo:@{kTagProductUserInfoEventKey:@(STTagManagerEventBrands)}];
        }
    };

        [STDataAccessUtils getBrandsEntitiesForPageNumber:_brandsPageIndex
                                           withCompletion:completion];
}

-(void)downloadProductsForCategoryAndBrand{
    if (_categoryAndBrondPageIndex == kCatalogNoMorePagesIndex) {
        NSLog(@"No more product to be downloaded for category: %@ and brand: %@", _selectedCategory.uuid, _selectedBrand.uuid);
        return;
    }
    __weak STTagProductsManager *weakSelf = self;

    [STDataAccessUtils getSuggestionsForCategory:_selectedCategory.uuid
                                        andBrand:_selectedBrand.uuid
                                    andPageIndex:_categoryAndBrondPageIndex
                                   andCompletion:^(NSArray *objects, NSError *error) {
                                       if (!error) {
                                           NSMutableArray *products = [NSMutableArray new];
                                           if (weakSelf.categoryAndBrandProducts) {
                                               [products addObjectsFromArray:weakSelf.categoryAndBrandProducts];
                                           }
                                           [products addObjectsFromArray:objects];
                                           weakSelf.categoryAndBrandProducts = [NSArray arrayWithArray:products];
                                           if ([objects count] < kCatalogDownloadPageSize) {
                                               NSLog(@"Products for categopry: %@ and brand: %@ STOP", _selectedCategory.uuid, _selectedBrand.uuid);
                                               weakSelf.categoryAndBrondPageIndex = kCatalogNoMorePagesIndex;
                                           }else{
                                               weakSelf.categoryAndBrondPageIndex ++;
                                           }
                                           [[NSNotificationCenter defaultCenter] postNotificationName:kTagProductNotification object:nil userInfo:@{kTagProductUserInfoEventKey:@(STTagManagerEventCategoryAndBrandProducts)}];
                                       }
                                   }];
}

@end

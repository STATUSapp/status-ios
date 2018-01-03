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
#import "STProductSuggestRequest.h"
#import "STSyncService.h"

NSString *const kTagProductNotification = @"STTagProductNotification";
NSString *const kTagProductUserInfoEventKey = @"notification_event";
NSString *const kTagProductUserInfoIndexKey = @"notification_index";

NSInteger const kCatalogFirstPage = 1;
NSInteger const kCatalogNoMorePagesIndex = -1;

@interface STTagProductsManager ()

@property (nonatomic, strong, readwrite) NSArray <STCatalogParentCategory *> *rootCategories;
@property (nonatomic, strong, readwrite) NSArray <STCatalogCategory *> *usedCategories;
@property (nonatomic, strong, readwrite) NSArray <STShopProduct *> *usedProducts;

@property (nonatomic, strong, readwrite) STCatalogCategory *selectedCategory;
@property (nonatomic, strong, readwrite) NSString *selectedBrandId;
@property (nonatomic, strong, readwrite) NSArray <STShopProduct *> *categoryAndBrandProducts;
@property (nonatomic, strong, readwrite) NSMutableArray<STShopProduct *> *selectedProducts;
@property (nonatomic, strong, readwrite) NSArray <STShopProduct *> *searchResult;

@property (nonatomic, assign) NSInteger usedCategoriesPageIndex;
@property (nonatomic, assign) NSInteger usedProductsPageIndex;
@property (nonatomic, assign) NSInteger barcodeProductsPageIndex;
@property (nonatomic, assign) NSInteger categoryAndBrondPageIndex;
@property (nonatomic, strong) NSMutableDictionary *rootCategoryPageIndexes;

@property (nonatomic, strong) NSString *scannedBarcode;
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
    _selectedBrandId = nil;
    _categoryAndBrandProducts = nil;
    _categoryAndBrondPageIndex = kCatalogFirstPage;
}

-(void)updateBrandId:(NSString *)brandId{
    if (![_selectedBrandId isEqualToString:brandId]) {
        _selectedBrandId = brandId;
        _categoryAndBrandProducts = nil;
        _categoryAndBrondPageIndex = kCatalogFirstPage;
        if (_selectedCategory) {
            [self downloadProductsForCategoryAndBrand];
        }
    }
}

-(void)resetManager{
    _selectedBrandId = nil;
    _selectedCategory = nil;
    _categoryAndBrandProducts = nil;
    _rootViewController = nil;
    _selectedProducts = nil;
    _usedCategoriesPageIndex = kCatalogFirstPage;
    _usedProductsPageIndex = kCatalogFirstPage;
    _barcodeProductsPageIndex = kCatalogFirstPage;
    _categoryAndBrondPageIndex = kCatalogFirstPage;
    _rootCategoryPageIndexes = nil;
    _searchResult = nil;
    _scannedBarcode = nil;
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
    _usedCategoriesPageIndex = kCatalogFirstPage;
    _usedProductsPageIndex = kCatalogFirstPage;
    _barcodeProductsPageIndex = kCatalogFirstPage;
    _categoryAndBrondPageIndex = kCatalogFirstPage;
    _rootCategoryPageIndexes = nil;
    [self downloadRootCatgories];
    [self downloadUsedCategories];
    [self downloadUsedProducts];
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

-(void)downloadBarcodeProducts{
    if (_barcodeProductsPageIndex == kCatalogNoMorePagesIndex) {
        NSLog(@"No more used products to be downloaded");
        return;
    }
    __weak STTagProductsManager *weakSelf = self;
    [STDataAccessUtils getUsedSuggestionsForCategory:nil
                                        andPageIndex:_barcodeProductsPageIndex
                                       andCompletion:^(NSArray *objects, NSError *error) {
                                           if (!error) {
                                               NSLog(@"Received objects: %@", objects);
                                               NSMutableArray *usedProducts = [NSMutableArray new];
                                               if (weakSelf.searchResult) {
                                                   [usedProducts addObjectsFromArray:weakSelf.searchResult];
                                               }
                                               [usedProducts addObjectsFromArray:objects];
                                               weakSelf.searchResult = [NSArray arrayWithArray:usedProducts];
                                               if ([objects count] < kCatalogDownloadPageSize) {
                                                   weakSelf.barcodeProductsPageIndex = kCatalogNoMorePagesIndex;
                                                   NSLog(@"Used products download STOP");
                                               }else{
                                                   weakSelf.barcodeProductsPageIndex ++;
                                               }
                                               [[NSNotificationCenter defaultCenter] postNotificationName:kTagProductNotification object:nil userInfo:@{kTagProductUserInfoEventKey:@(STTagManagerEventSearchProducts)}];
                                           }
                                       }];
    
}


-(void)downloadBrands{
    [[CoreManager syncService] syncBrands];
}

-(void)downloadProductsForCategoryAndBrand{
    if (_categoryAndBrondPageIndex == kCatalogNoMorePagesIndex) {
        NSLog(@"No more product to be downloaded for category: %@ and brand: %@", _selectedCategory.uuid, _selectedBrandId);
        return;
    }
    __weak STTagProductsManager *weakSelf = self;

    [STDataAccessUtils getSuggestionsForCategory:_selectedCategory.uuid
                                        andBrand:_selectedBrandId
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
                                               NSLog(@"Products for categopry: %@ and brand: %@ STOP", _selectedCategory.uuid, _selectedBrandId);
                                               weakSelf.categoryAndBrondPageIndex = kCatalogNoMorePagesIndex;
                                           }else{
                                               weakSelf.categoryAndBrondPageIndex ++;
                                           }
                                           [[NSNotificationCenter defaultCenter] postNotificationName:kTagProductNotification object:nil userInfo:@{kTagProductUserInfoEventKey:@(STTagManagerEventCategoryAndBrandProducts)}];
                                       }
                                   }];
}

-(void)searchProductWithBarcodeString:(NSString *)barcode{
    if ([_scannedBarcode isEqualToString:barcode]) {
        //ignore
        return;
    }
    _searchResult = nil;
    _scannedBarcode = barcode;
    _barcodeProductsPageIndex = kCatalogFirstPage;
    [self downloadBarcodeProducts];
//    NSInteger randomProductsFound = (random() % 2);
//    if (randomProductsFound == 1 && _usedProducts.count > 0) {
//        NSInteger randomIndex = (random() % _usedProducts.count);
//        _searchResult = [NSArray arrayWithObject:_usedProducts[randomIndex]];
//        //reset the _scannedBarcode after fetching
//    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:kTagProductNotification object:nil userInfo:@{kTagProductUserInfoEventKey:@(STTagManagerEventSearchProducts)}];
//
}

-(void)sendSuggestionWithBrand:(NSString *)brand
                   productName:(NSString *)productName
                         store:(NSString *)store{
    if (_scannedBarcode) {
        [STProductSuggestRequest suggestProductWithBarcode:_scannedBarcode
                                                     brand:brand
                                               productName:productName
                                                     store:store
                                             andCompletion:^(id response, NSError *error) {
                                                 NSLog(@"Send suggestion success: %@", @(error==nil));
                                             } failure:^(NSError *error) {
                                                 NSLog(@"Send suggestion Error: %@", error.debugDescription);
                                             }];
        [self resetLastScannedBarcode];
    }
}

-(void)resetLastScannedBarcode{
    _scannedBarcode = nil;
}
@end

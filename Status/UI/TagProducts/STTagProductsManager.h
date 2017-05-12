//
//  STTagProductsManager.h
//  Status
//
//  Created by Cosmin Andrus on 01/05/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kTagProductNotification;
extern NSString *const kTagProductUserInfoEventKey;
extern NSString *const kTagProductUserInfoIndexKey;

typedef NS_ENUM(NSUInteger, STTagManagerEvent) {
    STTagManagerEventRootCategoriesDownloaded,
    STTagManagerEventRootCategoriesUpdated,
    STTagManagerEventUsedCategories,
    STTagManagerEventUsedProducts,
    STTagManagerEventBrands,
    STTagManagerEventCategoryAndBrandProducts,
    STTagManagerEventSelectedProducts
};

@class STCatalogParentCategory;
@class STCatalogCategory;
@class STShopProduct;
@class STBrandObj;

@interface STTagProductsManager : NSObject

@property (nonatomic, strong, readonly) NSArray <STCatalogParentCategory *> *rootCategories;
@property (nonatomic, strong, readonly) NSArray <STCatalogCategory *> *usedCategories;
@property (nonatomic, strong, readonly) NSArray <STShopProduct *> *usedProducts;
@property (nonatomic, strong, readonly) NSArray <STBrandObj *> *brands;
@property (nonatomic, strong, readonly) STCatalogCategory *selectedCategory;
@property (nonatomic, strong, readonly) STBrandObj *selectedBrand;
@property (nonatomic, strong, readonly) NSArray <STShopProduct *> *categoryAndBrandProducts;

@property (nonatomic, strong, readonly) NSMutableArray<STShopProduct *> *selectedProducts;

//used to pop navigation to it when products were selected
@property (nonatomic, strong) UIViewController *rootViewController;

+(STTagProductsManager *) sharedInstance;

-(void)startDownload;
-(void)updateCategory:(STCatalogCategory *)category;
-(void)updateBrand:(STBrandObj *)brand;
-(void)resetManager;
-(void)processProduct:(STShopProduct *)product;
-(BOOL)isProductSelected:(STShopProduct *)product;
-(BOOL)rootCategoriesDownloaded;
-(NSArray <STShopProduct *> *)manualAddedProducts;
@end

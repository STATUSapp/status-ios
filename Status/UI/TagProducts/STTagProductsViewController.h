//
//  STTagProductsViewController.h
//  Status
//
//  Created by Cosmin Andrus on 05/05/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class STShopProduct;

@protocol STTagProductsProtocol <NSObject>

@required
-(void)addProductsAction;
-(void)productsShouldDownloadNextPage;
-(BOOL)isProductSelected:(STShopProduct *)product;
-(void)selectProduct:(STShopProduct *)product;
-(NSInteger)selectedProductCount;
-(NSString *)bottomActionString;

@end


@interface STTagProductsViewController : UIViewController

-(void)updateProducts:(NSArray<STShopProduct *> *)products;

@property (nonatomic, weak) id<STTagProductsProtocol>delegate;

@end

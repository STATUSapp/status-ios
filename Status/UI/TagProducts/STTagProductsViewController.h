//
//  STTagProductsViewController.h
//  Status
//
//  Created by Cosmin Andrus on 05/05/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol STTagProductsProtocol <NSObject>

-(void)addProductsAction;

@end

@class STShopProduct;

@interface STTagProductsViewController : UIViewController

-(void)updateProducts:(NSArray<STShopProduct *> *)products;

@property (nonatomic, weak) id<STTagProductsProtocol>delegate;

@end

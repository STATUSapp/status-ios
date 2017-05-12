//
//  STTagManualViewController.h
//  Status
//
//  Created by Cosmin Andrus on 07/05/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STTagManualProtocol <NSObject>

-(void)manualProductsAdded;

@end

@class STShopProduct;

@interface STTagManualViewController : UIViewController

@property (nonatomic, weak) id<STTagManualProtocol>delegate;
-(void)updateProducts:(NSArray<STShopProduct *> *)products;

@end

//
//  STTagProductsCategories.h
//  Status
//
//  Created by Cosmin Andrus on 30/04/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STCatalogCategory.h"

@protocol STTagCategoriesProtocol <NSObject>

-(void)categoryWasSelected:(STCatalogCategory *)category;

@end

@interface STTagProductsCategories : UIViewController

@property (nonatomic, weak) id<STTagCategoriesProtocol>delegate;

+(STTagProductsCategories *)newController;

-(void)updateCategories:(NSArray <STCatalogCategory *> *)categories;

@end

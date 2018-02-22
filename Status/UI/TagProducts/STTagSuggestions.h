//
//  STTagSuggestions.h
//  Status
//
//  Created by Cosmin Andrus on 06/05/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STShopProduct;

typedef NS_ENUM(NSUInteger, STTagSuggestionsScreenType) {
    STTagSuggestionsScreenTypeDefault = 0,//based on brand and category
    STTagSuggestionsScreenTypeBarcodeSearch,
    STTagSuggestionsScreenTypeSimilarProducts
};

typedef void (^STTagSuggestionsCompletion)(STShopProduct *selectedProduct);


@interface STTagSuggestions : UIViewController

+(STTagSuggestions *)suggestionsVCWithScreenType:(STTagSuggestionsScreenType)screenType;

+(STTagSuggestions *)similarProductsScreenWithProducts:(NSArray <STShopProduct *> *)similarProducts andSelectedProduct:(STShopProduct *)selectedProduct withCompletion:(STTagSuggestionsCompletion)completion;

@end

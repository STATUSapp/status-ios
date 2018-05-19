//
//  STTagSuggestions.h
//  Status
//
//  Created by Cosmin Andrus on 06/05/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STShopProduct;
@class STSuggestedProduct;

typedef NS_ENUM(NSUInteger, STTagSuggestionsScreenType) {
    STTagSuggestionsScreenTypeDefault = 0,//based on brand and category
    STTagSuggestionsScreenTypeBarcodeSearch,
    STTagSuggestionsScreenTypeSimilarProducts
};

typedef void (^STTagSuggestionsCompletion)(STSuggestedProduct *selectedProduct);


@interface STTagSuggestions : UIViewController

+(STTagSuggestions *)suggestionsVCWithScreenType:(STTagSuggestionsScreenType)screenType;

+(STTagSuggestions *)similarProductsScreenWithSelectedProduct:(STSuggestedProduct *)selectedProduct withCompletion:(STTagSuggestionsCompletion)completion;

@end

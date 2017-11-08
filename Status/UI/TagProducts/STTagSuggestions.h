//
//  STTagSuggestions.h
//  Status
//
//  Created by Cosmin Andrus on 06/05/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STWhiteNavBarViewController.h"
typedef NS_ENUM(NSUInteger, STTagSuggestionsScreenType) {
    STTagSuggestionsScreenTypeDefault = 0,//based on brand and category
    STTagSuggestionsScreenTypeBarcodeSearch,
};
@interface STTagSuggestions : STWhiteNavBarViewController

+(STTagSuggestions *)suggestionsVCWithScreenType:(STTagSuggestionsScreenType)screenType;

@end

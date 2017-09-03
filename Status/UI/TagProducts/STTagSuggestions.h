//
//  STTagSuggestions.h
//  Status
//
//  Created by Cosmin Andrus on 06/05/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STWhiteNavBarViewController.h"

@protocol STTagSuggestionsProtocol <NSObject>

-(void)categoryAndBrandProductsShouldDownloadNextPage;

@end

@interface STTagSuggestions : STWhiteNavBarViewController

@property (nonatomic, strong) id<STTagSuggestionsProtocol>delegate;
+(STTagSuggestions *)suggestionsVCWithDelegate:(id<STTagSuggestionsProtocol>)delegate;

@end

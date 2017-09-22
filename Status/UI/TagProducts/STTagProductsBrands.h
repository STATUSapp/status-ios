//
//  STTagProductsBrands.h
//  Status
//
//  Created by Cosmin Andrus on 06/05/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STWhiteNavBarViewController.h"

@protocol STTagBrandsProtocol <NSObject>

-(void)brandsShouldDownloadNextPage;

@end
@protocol STTagSuggestionsProtocol;
@interface STTagProductsBrands : STWhiteNavBarViewController
@property (nonatomic, strong) id<STTagBrandsProtocol, STTagSuggestionsProtocol>delegate;

+(STTagProductsBrands *)brandsViewControllerWithDelegate:(id<STTagBrandsProtocol>)delegate;

@end

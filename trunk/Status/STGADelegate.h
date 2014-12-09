//
//  STGADelegate.h
//  Status
//
//  Created by Cosmin Andrus on 01/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GADInterstitial.h"

@interface STGADelegate : NSObject
@property(nonatomic, strong) GADInterstitial * interstitial;
- (void)setupInterstitialAds;
@end

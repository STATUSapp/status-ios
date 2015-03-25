//
//  STGADelegate.m
//  Status
//
//  Created by Cosmin Andrus on 01/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STGADelegate.h"

@interface STGADelegate ()<GADInterstitialDelegate>{
    BOOL _isInterstitialLoaded;
}

@end

@implementation STGADelegate

- (void)setupInterstitialAds {
    _interstitial.delegate = nil;
    _interstitial = nil;
    
    _interstitial = [[GADInterstitial alloc] init];
    _interstitial.adUnitID = kSTAdUnitID;
    
    //    request.testDevices = @[GAD_SIMULATOR_ID];
    
    [_interstitial loadRequest:[GADRequest request]];
    _interstitial.delegate = self;
    _isInterstitialLoaded = NO;
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    _isInterstitialLoaded = NO;
    NSLog(@"error %@", error.localizedDescription);
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    _isInterstitialLoaded = YES;
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    [self setupInterstitialAds];
}
@end

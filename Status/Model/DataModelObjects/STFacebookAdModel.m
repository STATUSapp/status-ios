//
//  STFacebookAdModel.m
//  Status
//
//  Created by Cosmin Andrus on 09/11/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STFacebookAdModel.h"

@interface STFacebookAdModel()<FBNativeAdDelegate>
@property (strong, nonatomic, readwrite) FBNativeAd *nativeAd;
@property (assign, nonatomic, readwrite) BOOL adLoaded;

@end

@implementation STFacebookAdModel

-(instancetype)init{
    self = [super init];
    if (self) {
        [self initNativeAd];
    }
    return self;
}

-(void)initNativeAd{
    if (_nativeAd) {
        _nativeAd.delegate = nil;
        _nativeAd = nil;
    }
    _nativeAd = [[FBNativeAd alloc] initWithPlacementID:@"642056059181757_1505991126121575"];
    _nativeAd.delegate = self;
    _nativeAd.mediaCachePolicy = FBNativeAdsCachePolicyAll;
    [_nativeAd loadAd];
}

#pragma mark - FBNativeAdDelegate

- (void)nativeAdDidLoad:(FBNativeAd *)nativeAd{
    _adLoaded = YES;
    [_delegate facebookAdLoaded];
}

- (void)nativeAdWillLogImpression:(FBNativeAd *)nativeAd{
    
}

- (void)nativeAd:(FBNativeAd *)nativeAd didFailWithError:(NSError *)error{
    NSLog(@"FBNativeAd failed: %@", error);
//    [self initNativeAd];
}

- (void)nativeAdDidClick:(FBNativeAd *)nativeAd{
    NSLog(@"Native Ad clicked");
}

- (void)nativeAdDidFinishHandlingClick:(FBNativeAd *)nativeAd{
    
}
@end

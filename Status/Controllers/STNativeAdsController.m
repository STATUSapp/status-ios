//
//  STNativeAdsController.m
//  Status
//
//  Created by Silviu Burlacu on 02/08/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//


#define PLACEMENT_ID @"1341234sadflkjhasdlfkjhasdf"

#import "STNativeAdsController.h"


@interface STNativeAdsController ()<FBNativeAdsManagerDelegate>
@property (nonatomic, strong) FBNativeAdsManager * adsManager;
@property (nonatomic, copy) STAdsRequestCompletion adsCompletion;
@property (nonatomic, assign) NSUInteger numberOfRequestedAds;
@end

@implementation STNativeAdsController


#pragma mark - init


+(instancetype) sharedInstance{
    static STNativeAdsController *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}


- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

#pragma mark - Public Methods


- (void)getAdsInBatchOf:(NSUInteger)numberOfAds withCompletion:(STAdsRequestCompletion)completion {
    _adsManager = [[FBNativeAdsManager alloc] initWithPlacementID:PLACEMENT_ID forNumAdsRequested:numberOfAds];
    _adsManager.delegate = self;
    [_adsManager loadAds];
    self.adsCompletion = completion;
}

#pragma mark - FBNativeAdsManager Delegate methods

- (void)nativeAdsFailedToLoadWithError:(NSError *)error {
    self.adsCompletion(nil, error);
}

- (void)nativeAdsLoaded {
    NSMutableArray * ads = [NSMutableArray array];
    for (NSUInteger i = 0; i < self.numberOfRequestedAds; i++) {
        FBNativeAd * nativeAdd = [_adsManager nextNativeAd];
        if (nativeAdd) {
            [ads addObject:nativeAdd];
        }
    }
    
    self.adsCompletion(ads, nil);
    
}

@end

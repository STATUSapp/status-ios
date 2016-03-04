//
//  STNativeAdsController.h
//  Status
//
//  Created by Silviu Burlacu on 02/08/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FBAudienceNetwork/FBAudienceNetwork.h>

typedef void (^STAdsRequestCompletion)(NSArray *response, NSError *error);

@interface STNativeAdsController : NSObject

- (void)getAdsInBatchOf:(NSUInteger)numberOfAds withCompletion:(STAdsRequestCompletion)completion;

@end

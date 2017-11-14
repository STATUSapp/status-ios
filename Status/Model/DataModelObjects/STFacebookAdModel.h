//
//  STFacebookAdModel.h
//  Status
//
//  Created by Cosmin Andrus on 09/11/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FBAudienceNetwork/FBAudienceNetwork.h>

@protocol STFacebookAdModelProtocol <NSObject>
-(void)facebookAdLoaded;
@end

@interface STFacebookAdModel : NSObject

@property (strong, nonatomic, readonly) FBNativeAd *nativeAd;
@property (assign, nonatomic, readonly) BOOL adLoaded;
@property (weak, nonatomic) id<STFacebookAdModelProtocol>delegate;
@end

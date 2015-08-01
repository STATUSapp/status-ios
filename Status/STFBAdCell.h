//
//  STFBAdCell.h
//  Status
//
//  Created by Cosmin Adelin Andrus on 27/07/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface STFBAdCell : UICollectionViewCell
-(void)configureCellWithFBNativeAdd:(FBNativeAd *)nativeAd;
@end

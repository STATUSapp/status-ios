//
//  NearbyCVC.h
//  Status
//
//  Created by Cosmin Andrus on 01/12/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STSideBySideContaineeProtocol.h"
#import "STSideBySideContainerProtocol.h"

@interface NearbyVC : UIViewController <STSideBySideContainerProtocol>

+ (NearbyVC *)nearbyFeedController;

@property (nonatomic, weak) id<STSideBySideContaineeProtocol> containeeDelegate;

@end

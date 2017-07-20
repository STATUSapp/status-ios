//
//  STEarningsViewController.h
//  Status
//
//  Created by Cosmin Andrus on 12/07/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STWhiteNavBarViewController.h"
#warning - remove this mock
typedef NS_ENUM(NSUInteger, STEarnigsScreenState) {
    STEarnigsScreenStateNormal = 0,
    STEarnigsScreenStateRemoveLastObject,
    STEarnigsScreenStateRemoveAll,
    STEarnigsScreenStateCount
};
@interface STEarningsViewController : STWhiteNavBarViewController

@property (nonatomic, assign) STEarnigsScreenState screenState;
@end

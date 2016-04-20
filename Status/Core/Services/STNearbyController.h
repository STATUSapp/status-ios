//
//  STNearbyController.h
//  Status
//
//  Created by Silviu Burlacu on 25/01/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^STCompletionBlock)(NSError *error);

@interface STNearbyController : NSObject

- (void)pushNearbyFlowFromController:(UIViewController *)viewController;

@end

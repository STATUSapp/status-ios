//
//  STSharePhotoViewController.h
//  Status
//
//  Created by Andrus Cosmin on 23/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMoveScaleViewController.h"
#import "STSharePhotoHeader.h"

@class STPost;

@interface STSharePhotoViewController : UIViewController
@property (nonatomic, strong) NSData *imgData;
@property (nonatomic, strong) STPost *post;
@property (nonatomic) STShareControllerType controllerType;
@end
